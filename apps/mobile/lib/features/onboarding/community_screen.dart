import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';
import '../auth/register_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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
                '🤝',
                style: TextStyle(fontSize: 72),
              ),

              const SizedBox(height: 32),

              const Text(
                'Helping each other\nmakes parking easier.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Every shared parking space helps another professional driver.\n\n'
                'Together we can reduce stress, save time and make the roads safer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Join the Community',
                onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const RegisterScreen(),
    ),
  );
},
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}