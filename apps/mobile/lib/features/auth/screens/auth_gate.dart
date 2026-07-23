import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/welcome_screen.dart';
import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  AuthGate({
    super.key,
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      initialData: _authService.currentUser,
      builder: (context, snapshot) {

  if (snapshot.connectionState == ConnectionState.waiting &&
      snapshot.data == null) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (snapshot.data != null) {
    debugPrint('AuthGate -> HomeScreen');
    return const HomeScreen();
  }

  debugPrint('AuthGate -> WelcomeScreen');
  return const WelcomeScreen();
},
    );
  }
}