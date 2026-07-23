import 'package:flutter/foundation.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    if (_isLoading) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    _setLoading(true);

    try {
      return await _authService.sendPasswordResetEmail(
        email: email.trim(),
      );
    } catch (error, stackTrace) {
      debugPrint('Password reset failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return const AuthResult.failure(
        AuthError.unknown,
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }
}