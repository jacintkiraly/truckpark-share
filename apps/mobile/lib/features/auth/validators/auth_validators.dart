import '../../../localization/generated/app_localizations.dart';

/// Validation helpers for authentication forms.
///
/// This class is intentionally stateless.
/// All user-facing messages come from AppLocalizations.
class AuthValidators {
  AuthValidators._();

  static String? validateName(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n.enterName;
    }

    if (text.length < 2) {
      return l10n.nameTooShort;
    }

    return null;
  }

  static String? validateEmail(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n.enterEmail;
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(text)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  static String? validatePassword(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value ?? '';

    if (text.isEmpty) {
      return l10n.enterPassword;
    }

    if (text.length < 8) {
      return l10n.passwordTooShort;
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    final text = value ?? '';

    if (text.isEmpty) {
      return l10n.confirmYourPassword;
    }

    if (text != password) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }
}