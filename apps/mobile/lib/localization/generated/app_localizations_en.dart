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
  String get continueButton => 'Continue';

  @override
  String get joinCommunity => 'Join the Community';

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
  String get signInPrompt => 'Already have an account? Sign In';

  @override
  String get languageDescription =>
      'TruckPark Share is available\nin multiple languages.';
}
