import 'package:flutter/foundation.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class RegisterController extends ChangeNotifier {
  RegisterController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      return await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      debugPrint('Registration failed: $e');
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