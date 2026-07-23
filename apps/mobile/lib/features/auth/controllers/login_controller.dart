import 'package:flutter/foundation.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Prevent duplicate login requests while one is already running.
    if (_isLoading) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    _setLoading(true);

    try {
      return await _authService.login(
        email: email.trim(),
        password: password,
      );
    } catch (error, stackTrace) {
      debugPrint('Login failed: $error');
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