// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TruckPark Share';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageDescription =>
      'TruckPark Share is available\nin multiple languages.';

  @override
  String get continueButton => 'Continue';

  @override
  String get welcomeTitle => 'TruckPark Share';

  @override
  String get welcomeSubtitle => 'Share your spot. Help the next driver.';

  @override
  String get welcomeDescription =>
      'Real-time truck parking availability\npowered by the driver community.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get joinCommunity => 'Join the Community';

  @override
  String get signInPrompt => 'Already have an account? Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle => 'Join the TruckPark Share community.';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String get enterName => 'Please enter your full name.';

  @override
  String get nameTooShort => 'Name must contain at least 2 characters.';

  @override
  String get enterEmail => 'Please enter your email address.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get enterPassword => 'Please enter your password.';

  @override
  String get passwordTooShort => 'Password must contain at least 8 characters.';

  @override
  String get confirmYourPassword => 'Please confirm your password.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account already exists with this email.';

  @override
  String get authErrorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrorWeakPassword => 'Your password is too weak.';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrorNetworkError =>
      'Network error. Please check your connection.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';
}
