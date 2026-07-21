import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registers a new user.
  Future<AuthResult> register({
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

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return const AuthResult.failure(
            AuthError.emailAlreadyInUse,
          );

        case 'invalid-email':
          return const AuthResult.failure(
            AuthError.invalidEmail,
          );

        case 'weak-password':
          return const AuthResult.failure(
            AuthError.weakPassword,
          );

        case 'network-request-failed':
          return const AuthResult.failure(
            AuthError.networkError,
          );

        case 'too-many-requests':
          return const AuthResult.failure(
            AuthError.tooManyRequests,
          );

        default:
          return const AuthResult.failure(
            AuthError.unknown,
          );
      }
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Signs an existing user in.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return const AuthResult.failure(
            AuthError.invalidCredentials,
          );

        case 'invalid-email':
          return const AuthResult.failure(
            AuthError.invalidEmail,
          );

        case 'network-request-failed':
          return const AuthResult.failure(
            AuthError.networkError,
          );

        case 'too-many-requests':
          return const AuthResult.failure(
            AuthError.tooManyRequests,
          );

        default:
          return const AuthResult.failure(
            AuthError.unknown,
          );
      }
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Returns true if a user is signed in.
  bool get isSignedIn => currentUser != null;
}