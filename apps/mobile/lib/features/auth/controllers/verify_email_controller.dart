import 'package:flutter/foundation.dart';

import '../models/auth_error.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class VerifyEmailController extends ChangeNotifier {
  VerifyEmailController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isSending = false;
  bool _isChecking = false;

  bool get isSending => _isSending;
  bool get isChecking => _isChecking;

  bool get isLoading => _isSending || _isChecking;

  String? get email => _authService.currentUser?.email;

  bool get isEmailVerified => _authService.isEmailVerified;

  Future<AuthResult> sendVerificationEmail() async {
    if (isLoading) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    _setSending(true);

    try {
      return await _authService.sendEmailVerification();
    } catch (error, stackTrace) {
      debugPrint('Sending verification email failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return const AuthResult.failure(
        AuthError.unknown,
      );
    } finally {
      _setSending(false);
    }
  }

  Future<AuthResult> checkVerificationStatus() async {
    if (isLoading) {
      return const AuthResult.failure(
        AuthError.unknown,
      );
    }

    _setChecking(true);

    try {
      final result = await _authService.reloadUser();

      if (!result.success) {
        return result;
      }

      if (_authService.isEmailVerified) {
        return const AuthResult.success();
      }

      return const AuthResult.failure(
        AuthError.emailNotVerified,
      );
    } catch (error, stackTrace) {
      debugPrint('Checking email verification failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return const AuthResult.failure(
        AuthError.unknown,
      );
    } finally {
      _setChecking(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setSending(bool value) {
    if (_isSending == value) return;

    _isSending = value;
    notifyListeners();
  }

  void _setChecking(bool value) {
    if (_isChecking == value) return;

    _isChecking = value;
    notifyListeners();
  }
}