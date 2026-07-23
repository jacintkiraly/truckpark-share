import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/forgot_password_controller.dart';
import '../helpers/auth_error_localizer.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final ForgotPasswordController _controller =
      ForgotPasswordController();

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final result = await _controller.sendPasswordResetEmail(
      email: _emailController.text,
    );

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (!result.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AuthErrorLocalizer.message(
                result.error,
                l10n,
              ),
            ),
          ),
        );

      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.passwordResetEmailSent,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  AuthHeader(
                    emoji: '🔐',
                    title: l10n.forgotPasswordTitle,
                    subtitle: l10n.forgotPasswordSubtitle,
                  ),

                  const SizedBox(height: 40),

                  AuthTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: 'john@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    validator: (value) {
                      return AuthValidators.validateEmail(
                        value,
                        l10n,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return PrimaryButton(
                        text: _controller.isLoading
                            ? l10n.sendingResetLink
                            : l10n.sendResetLink,
                        onPressed: _controller.isLoading
                            ? null
                            : _sendResetLink,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _controller.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.backToSignIn),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}