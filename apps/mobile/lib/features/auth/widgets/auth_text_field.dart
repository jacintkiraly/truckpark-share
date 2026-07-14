import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;

  final String label;
  final String? hint;

  final IconData icon;

  final TextInputType? keyboardType;

  final String? Function(String?)? validator;

  final bool obscureText;

  final TextInputAction textInputAction;

  final bool enabled;

  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
  labelText: label,
  hintText: hint,
  prefixIcon: Icon(icon),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 18,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
),
    );
  }
}