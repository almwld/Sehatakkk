import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RegistrationResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? errorMessage;
  final Map<String, dynamic>? validationErrors;

  RegistrationResult({
    required this.success,
    this.userId,
    this.email,
    this.errorMessage,
    this.validationErrors,
  });

  factory RegistrationResult.success({required String userId, String? email}) =>
      RegistrationResult(success: true, userId: userId, email: email);

  factory RegistrationResult.failure(String error, {Map<String, dynamic>? validationErrors}) =>
      RegistrationResult(success: false, errorMessage: error, validationErrors: validationErrors);
}

class RegistrationData {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String? dateOfBirth;
  final String? gender;
  final String? city;

  RegistrationData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.dateOfBirth,
    this.gender,
    this.city,
  });
}

class RegistrationService {
  static final RegistrationService _instance = RegistrationService._internal();
  factory RegistrationService() => _instance;
  RegistrationService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RegistrationResult> register(RegistrationData data) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim(),
        password: data.password,
      );

      final User? user = userCredential.user;
      if (user == null) return RegistrationResult.failure('فشل إنشاء الحساب');

      await user.updateDisplayName(data.fullName.trim());
      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': data.fullName.trim(),
        'phoneNumber': data.phone.trim(),
        'dateOfBirth': data.dateOfBirth,
        'gender': data.gender,
        'city': data.city,
        'authProvider': 'email',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'patient',
      });

      return RegistrationResult.success(userId: user.uid, email: user.email);
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        case 'weak-password':
          message = 'كلمة المرور ضعيفة جداً';
          break;
        default:
          message = e.message ?? 'حدث خطأ غير متوقع';
      }
      return RegistrationResult.failure(message);
    } catch (e) {
      return RegistrationResult.failure('حدث خطأ غير متوقع');
    }
  }
}
