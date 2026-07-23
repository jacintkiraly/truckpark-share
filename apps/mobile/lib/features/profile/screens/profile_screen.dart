import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _authService.signOut();

      // No manual navigation.
      // AuthGate reacts to Firebase authentication state
      // and returns the user to the signed-out experience.
    } catch (error, stackTrace) {
      debugPrint('Sign out failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSigningOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ProfileHeader(
              user: user,
              fallbackName: l10n.profileNoName,
            ),

            const SizedBox(height: 32),

            Text(
              l10n.profileAccount,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(l10n.profileName),
                    subtitle: Text(
                      _displayName(
                        user,
                        l10n.profileNoName,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(l10n.profileEmail),
                    subtitle: Text(user?.email ?? '—'),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.verified_user_outlined,
                    ),
                    title: Text(l10n.profileEmailStatus),
                    subtitle: Text(
                      user?.emailVerified == true
                          ? l10n.profileEmailVerified
                          : l10n.profileEmailNotVerified,
                    ),
                  ),

                  const Divider(height: 1),

                  AnimatedBuilder(
                    animation:
                        TruckParkShareApp.languageController,
                    builder: (context, child) {
                      final languageCode =
                          TruckParkShareApp
                              .languageController
                              .languageCode;

                      return ListTile(
                        leading: const Icon(
                          Icons.language_outlined,
                        ),
                        title: Text(l10n.profileLanguage),
                        subtitle: Text(
                          _languageName(languageCode),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: _isSigningOut
                  ? l10n.signingOut
                  : l10n.signOut,
              onPressed:
                  _isSigningOut ? null : _signOut,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _displayName(
    User? user,
    String fallback,
  ) {
    final name = user?.displayName?.trim();

    if (name == null || name.isEmpty) {
      return fallback;
    }

    return name;
  }

  String _languageName(String languageCode) {
    switch (languageCode) {
      case 'hu':
        return 'Magyar';

      case 'en':
      default:
        return 'English';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.fallbackName,
  });

  final User? user;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();

    final name =
        displayName == null || displayName.isEmpty
            ? fallbackName
            : displayName;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          child: Text(
            _initial(name),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        if (user?.email != null) ...[
          const SizedBox(height: 4),

          Text(
            user!.email!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed.characters.first.toUpperCase();
  }
}