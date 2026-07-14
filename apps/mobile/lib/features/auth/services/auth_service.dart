import 'package:firebase_auth/firebase_auth.dart';

import '../models/register_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(fullName.trim());

      await credential.user?.reload();

      return const RegisterResult(
        success: true,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return const RegisterResult(
            success: false,
            message: 'An account with this email already exists.',
          );

        case 'invalid-email':
          return const RegisterResult(
            success: false,
            message: 'The email address is invalid.',
          );

        case 'weak-password':
          return const RegisterResult(
            success: false,
            message: 'Please choose a stronger password.',
          );

        default:
          return RegisterResult(
            success: false,
            message: e.message ?? 'Authentication failed.',
          );
      }
    } catch (_) {
      return const RegisterResult(
        success: false,
        message: 'Unexpected error occurred.',
      );
    }
  }
}