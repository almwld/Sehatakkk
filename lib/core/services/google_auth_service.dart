import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;
  final bool isNewUser;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
    this.isNewUser = false,
  });

  factory AuthResult.success({
    required String userId,
    String? email,
    String? displayName,
    String? photoUrl,
    bool isNewUser = false,
  }) => AuthResult(
    success: true,
    userId: userId,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    isNewUser: isNewUser,
  );

  factory AuthResult.failure(String error) => AuthResult(
    success: false,
    errorMessage: error,
  );
}

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.failure('تم إلغاء تسجيل الدخول');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.failure('فشل الحصول على معلومات المصادقة');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) return AuthResult.failure('فشل تسجيل الدخول إلى Firebase');

      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      await _updateUserData(user, isNewUser);

      return AuthResult.success(
        userId: user.uid,
        email: user.email,
        displayName: user.displayName ?? googleUser.displayName,
        photoUrl: user.photoURL ?? googleUser.photoUrl,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'خطأ في تسجيل الدخول');
    } catch (e) {
      return AuthResult.failure('حدث خطأ غير متوقع');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _updateUserData(User user, bool isNewUser) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      if (isNewUser) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'authProvider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'role': 'patient',
        });
      } else {
        await userRef.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } catch (e) {
      debugPrint('Failed to update user data: $e');
    }
  }
}
