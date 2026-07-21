import '../models/auth_error.dart';

class AuthResult {
  final bool success;
  final AuthError? error;

  const AuthResult({
    required this.success,
    this.error,
  });

  const AuthResult.success()
      : success = true,
        error = null;

  const AuthResult.failure(this.error)
      : success = false;
}