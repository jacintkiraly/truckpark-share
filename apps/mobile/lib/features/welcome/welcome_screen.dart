import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';

import '../onboarding/language_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              const Text(
                '🚛',
                style: TextStyle(fontSize: 72),
              ),

              const SizedBox(height: 24),

              const Text(
                'TruckPark Share',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Share your spot.\nHelp the next driver.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Real-time truck parking availability\npowered by the driver community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  debugPrint('Sign In pressed');
                },
                child: const Text('Already have an account? Sign In'),
              ),

              const SizedBox(height: 16),

              const Text(
                'Version 0.1.0-alpha',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}