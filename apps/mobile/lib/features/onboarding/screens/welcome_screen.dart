import 'package:flutter/material.dart';

import '../../../shared/widgets/primary_button.dart';

import 'language_screen.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../auth/screens/login_screen.dart';

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

              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context)!.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)!.welcomeDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: AppLocalizations.of(context)!.getStarted,
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.signInPrompt,
                ),
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