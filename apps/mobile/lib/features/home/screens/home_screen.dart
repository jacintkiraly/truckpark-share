import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _authService.signOut();

      // No Navigator call is needed here.
      // AuthGate will detect the Firebase auth-state change
      // and automatically show the unauthenticated experience.
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _authService.currentUser;

    final displayName = user?.displayName?.trim();
    final email = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Text(
                '🚛',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 72),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.homeWelcome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (displayName != null && displayName.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],

              if (email != null) ...[
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],

              const SizedBox(height: 24),

              Text(
                l10n.homePlaceholderDescription,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              PrimaryButton(
                text: _isSigningOut
                    ? l10n.signingOut
                    : l10n.signOut,
                onPressed: _isSigningOut ? null : _signOut,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}