import '../../../localization/generated/app_localizations.dart';

import '../models/auth_error.dart';

class AuthErrorLocalizer {
  const AuthErrorLocalizer._();

  static String message(
    AuthError? error,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case AuthError.emailAlreadyInUse:
        return l10n.authErrorEmailAlreadyInUse;

      case AuthError.invalidEmail:
        return l10n.authErrorInvalidEmail;

      case AuthError.weakPassword:
        return l10n.authErrorWeakPassword;

      case AuthError.invalidCredentials:
        return l10n.authErrorInvalidCredentials;

      case AuthError.tooManyRequests:
        return l10n.authErrorTooManyRequests;

      case AuthError.networkError:
        return l10n.authErrorNetworkError;

      case AuthError.emailNotVerified:
        return l10n.authErrorEmailNotVerified;

      case AuthError.unknown:
      case null:
        return l10n.authErrorUnknown;
    }
  }
}