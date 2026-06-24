import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
class RegisterRequested extends AuthEvent {
  final String name, email, phone, password;
  const RegisterRequested({required this.name, required this.email, required this.phone, required this.password});
  @override
  List<Object?> get props => [name, email, phone, password];
}
class LogoutRequested extends AuthEvent {}
class LoginWithGoogle extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<LoginWithGoogle>(_onLoginWithGoogle);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _auth.currentUser;
    if (user != null) emit(AuthAuthenticated(user));
    else emit(AuthUnauthenticated());
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل تسجيل الدخول'));
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: event.email, password: event.password);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': event.name,
        'email': event.email,
        'phone': event.phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل إنشاء الحساب'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) { emit(AuthUnauthenticated()); return; }
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken);
      final result = await _auth.signInWithCredential(cred);
      emit(AuthAuthenticated(result.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
