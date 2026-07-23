import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/verify_email_controller.dart';
import '../helpers/auth_error_localizer.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.onVerified,
  });

  final VoidCallback onVerified;

  @override
  State<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final VerifyEmailController _controller =
      VerifyEmailController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _sendVerificationEmail() async {
    final result = await _controller.sendVerificationEmail();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (result.success) {
      widget.onVerified();
      return;
    }

    _showMessage(
      AuthErrorLocalizer.message(
        result.error,
        l10n,
      ),
    );
  }

  Future<void> _checkVerificationStatus() async {
    final result = await _controller.checkVerificationStatus();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (result.success) {
      _showMessage(
        l10n.emailVerifiedSuccessfully,
      );

      // We do not manually navigate to HomeScreen.
      //
      // AuthGate will become responsible for detecting the
      // refreshed verified user and showing HomeScreen.
      return;
    }

    if (result.error != null) {
      _showMessage(
        AuthErrorLocalizer.message(
          result.error,
          l10n,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await _controller.signOut();

    // No navigation is needed.
    // AuthGate reacts to the Firebase sign-out event.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = _controller.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  const Text(
                    '✉️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 72,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    l10n.verifyEmailTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    l10n.verifyEmailSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  if (email != null &&
                      email.isNotEmpty) ...[
                    const SizedBox(height: 24),

                    Text(
                      l10n.verificationEmailAddress,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Text(
                    l10n.verifyEmailInstructions,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  PrimaryButton(
                    text: _controller.isChecking
                        ? l10n.checkingVerification
                        : l10n.checkVerification,
                    onPressed: _controller.isLoading
                        ? null
                        : _checkVerificationStatus,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: _controller.isLoading
                        ? null
                        : _sendVerificationEmail,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Text(
                        _controller.isSending
                            ? l10n.sendingVerificationEmail
                            : l10n.sendVerificationEmail,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed:
                        _controller.isLoading
                            ? null
                            : _signOut,
                    child: Text(l10n.signOut),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}