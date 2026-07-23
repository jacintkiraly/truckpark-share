import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';

class AuthService {
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Registers a new user with email and password.
  ///
  /// After registration, the user's Firebase display name is updated
  /// with the provided full name.
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

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(fullName.trim());
        await user.reload();
      }

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Signs an existing user in with email and password.
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
      return _mapFirebaseAuthException(
        e,
        invalidCredentialsForLogin: true,
      );
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Sends a password-reset email.
  ///
  /// If Firebase reports `user-not-found`, this still returns success.
  /// This avoids exposing whether a particular email address has an
  /// account registered with the app.
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const AuthResult.success();
      }

      return _mapFirebaseAuthException(e);
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Sends an email-verification message to the currently signed-in user.
  Future<AuthResult> sendEmailVerification() async {
    final user = currentUser;

    if (user == null) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    if (user.emailVerified) {
      return const AuthResult.success();
    }

    try {
      await user.sendEmailVerification();

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (_) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }
  }

  /// Reloads the currently signed-in user's Firebase data.
  Future<AuthResult> reloadUser() async {
    final user = currentUser;

    if (user == null) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    try {
      await user.reload();

      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
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

  /// Currently signed-in Firebase user.
  ///
  /// Returns null when no user is authenticated.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Whether the current user's email address has been verified.
  bool get isEmailVerified =>
      currentUser?.emailVerified ?? false;

  /// Emits authentication-state changes.
  ///
  /// We will use this later in AuthGate so the UI automatically reacts
  /// when a user signs in or signs out.
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  /// Converts Firebase-specific exceptions into app-level AuthError values.
  ///
  /// Firebase details stay inside this service. Controllers and screens
  /// only need to understand AuthResult and AuthError.
  AuthResult _mapFirebaseAuthException(
    FirebaseAuthException exception, {
    bool invalidCredentialsForLogin = false,
  }) {
    switch (exception.code) {
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

      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        if (invalidCredentialsForLogin) {
          return const AuthResult.failure(
            AuthError.invalidCredentials,
          );
        }

        return const AuthResult.failure(
          AuthError.unknown,
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
  }
}