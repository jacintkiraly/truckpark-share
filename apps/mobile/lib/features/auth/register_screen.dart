import 'package:flutter/material.dart';

import '../../shared/widgets/primary_button.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_field.dart';
import 'validators/auth_validators.dart';
import 'controllers/register_controller.dart';

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
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final result = await _controller.register(
  fullName: _nameController.text.trim(),
  email: _emailController.text.trim(),
  password: _passwordController.text,
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      result.success
          ? 'Registration successful!'
          : result.message ?? 'Registration failed.',
    ),
  ),
);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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

                const AuthHeader(
                  emoji: '🚛',
                  title: 'Create your account',
                  subtitle: 'Join the TruckPark Share community.',
                ),

                const SizedBox(height: 40),

                AuthTextField(
  controller: _nameController,
  label: 'Full name',
  hint: 'John Smith',
  icon: Icons.person,
  validator: AuthValidators.validateName,
),

                const SizedBox(height: 16),

                AuthTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'john@example.com',
  icon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: AuthValidators.validateEmail,
),

                const SizedBox(height: 16),

                PasswordField(
  controller: _passwordController,
  label: 'Password',
  validator: AuthValidators.validatePassword,
),

                const SizedBox(height: 16),

                PasswordField(
  controller: _confirmPasswordController,
  label: 'Confirm password',
  textInputAction: TextInputAction.done,
  validator: (value) => AuthValidators.validateConfirmPassword(
    value,
    _passwordController.text,
  ),
),

                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return PrimaryButton(
                    text: _controller.isLoading
                        ? 'Creating account...'
                        : 'Create Account',
                    onPressed: _controller.isLoading
                        ? null
                        : _createAccount,
                    );
                  },
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    debugPrint('Navigate to Login');
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                  ),
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