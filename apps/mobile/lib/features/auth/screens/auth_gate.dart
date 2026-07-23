import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/screens/driver_home_screen.dart';
import '../../onboarding/screens/welcome_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  void _handleEmailVerified() {
    if (!mounted) return;

    setState(() {
      // Rebuild AuthGate using FirebaseAuth.instance.currentUser.
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user =
            FirebaseAuth.instance.currentUser ?? snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting &&
            user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (user == null) {
          return const WelcomeScreen();
        }

        if (!user.emailVerified) {
          return VerifyEmailScreen(
            onVerified: _handleEmailVerified,
          );
        }

        return const DriverHomeScreen();
      },
    );
  }
}