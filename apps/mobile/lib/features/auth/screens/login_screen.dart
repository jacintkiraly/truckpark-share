import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/login_controller.dart';
import '../helpers/auth_error_localizer.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final result = await _controller.login(
      email: _emailController.text,
      password: _passwordController.text,
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

// Firebase is now authenticated.
// AuthGate rebuilds its root to HomeScreen.
//
// Wait until that rebuild completes, then remove all
// authentication routes sitting above the root.
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  Navigator.of(context).popUntil(
    (route) => route.isFirst,
  );
});

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.loginSuccessful),
        ),
      );

    // Do not manually navigate to the authenticated area here.
    //
    // AuthGate will become the single source of truth for deciding
    // whether the user sees the authenticated or unauthenticated app.
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signIn),
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
                    emoji: '🚛',
                    title: l10n.loginTitle,
                    subtitle: l10n.loginSubtitle,
                  ),

                  const SizedBox(height: 40),

                  AuthTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: 'john@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username,
                    ],
                    validator: (value) {
                      return AuthValidators.validateEmail(
                        value,
                        l10n,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  PasswordField(
                    controller: _passwordController,
                    label: l10n.password,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.password,
                    ],
                    validator: (value) {
                      return AuthValidators.validatePassword(
                        value,
                        l10n,
                      );
                    },
                    onSubmitted: (_) {
                      if (!_controller.isLoading) {
                        _login();
                      }
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openForgotPassword,
                      child: Text(l10n.forgotPassword),
                    ),
                  ),

                  const SizedBox(height: 16),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return PrimaryButton(
                        text: _controller.isLoading
                            ? l10n.signingIn
                            : l10n.signIn,
                        onPressed:
                            _controller.isLoading ? null : _login,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _openRegister,
                    child: Text(l10n.noAccountPrompt),
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