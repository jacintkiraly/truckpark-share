import '../models/register_result.dart';

class AuthService {
  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // TODO: Replace this with Firebase Authentication.
    await Future.delayed(const Duration(seconds: 2));

    return const RegisterResult(
      success: true,
    );
  }
}