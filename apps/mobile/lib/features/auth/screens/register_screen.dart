import 'package:flutter/material.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';

import '../controllers/register_controller.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../helpers/auth_error_localizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final RegisterController _controller = RegisterController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await _controller.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

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

WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  Navigator.of(context).popUntil(
    (route) => route.isFirst,
  );
});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                AuthHeader(
                  emoji: '🚛',
                  title: l10n.createAccountTitle,
                  subtitle: l10n.createAccountSubtitle,
                ),

                const SizedBox(height: 40),

                AuthTextField(
                  controller: _nameController,
                  label: l10n.fullName,
                  hint: 'John Smith',
                  icon: Icons.person,
                  validator: (value) =>
                      AuthValidators.validateName(value, l10n),
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: 'john@example.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      AuthValidators.validateEmail(value, l10n),
                ),

                const SizedBox(height: 16),

                PasswordField(
                  controller: _passwordController,
                  label: l10n.password,
                  validator: (value) =>
                      AuthValidators.validatePassword(value, l10n),
                ),

                const SizedBox(height: 16),

                PasswordField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      AuthValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                    l10n,
                  ),
                ),

                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return PrimaryButton(
                      text: _controller.isLoading
                          ? l10n.creatingAccount
                          : l10n.createAccount,
                      onPressed:
                          _controller.isLoading ? null : _createAccount,
                    );
                  },
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    debugPrint('Navigate to Login');
                  },
                  child: Text(l10n.signInPrompt),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}