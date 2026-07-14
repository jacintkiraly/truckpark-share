import 'package:flutter/foundation.dart';

import '../models/register_result.dart';
import '../services/auth_service.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      // TODO: Replace with Firebase Authentication.
    return await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    } catch (e) {
      debugPrint('Registration failed: $e');

      return const RegisterResult(
        success: false,
        message: 'Registration failed.',
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}