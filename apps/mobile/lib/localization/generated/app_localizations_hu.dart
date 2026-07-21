// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'TruckPark Share';

  @override
  String get chooseLanguage => 'Válassz nyelvet';

  @override
  String get languageDescription =>
      'A TruckPark Share\ntöbb nyelven is elérhető.';

  @override
  String get continueButton => 'Folytatás';

  @override
  String get welcomeTitle => 'TruckPark Share';

  @override
  String get welcomeSubtitle =>
      'Oszd meg a helyed. Segíts a következő sofőrnek.';

  @override
  String get welcomeDescription =>
      'Valós idejű kamionparkoló-információ\nkamionosok közösségétől.';

  @override
  String get getStarted => 'Kezdjük';

  @override
  String get joinCommunity => 'Csatlakozz a közösséghez';

  @override
  String get signInPrompt => 'Már van fiókod? Jelentkezz be';

  @override
  String get createAccount => 'Fiók létrehozása';

  @override
  String get createAccountTitle => 'Hozd létre a fiókodat';

  @override
  String get createAccountSubtitle =>
      'Csatlakozz a TruckPark Share közösségéhez.';

  @override
  String get fullName => 'Teljes név';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Jelszó';

  @override
  String get confirmPassword => 'Jelszó megerősítése';

  @override
  String get creatingAccount => 'Fiók létrehozása...';

  @override
  String get registrationSuccessful => 'A regisztráció sikeres!';

  @override
  String get registrationFailed => 'A regisztráció sikertelen.';

  @override
  String get enterName => 'Kérjük, add meg a teljes nevedet.';

  @override
  String get nameTooShort => 'A névnek legalább 2 karakterből kell állnia.';

  @override
  String get enterEmail => 'Kérjük, add meg az e-mail címedet.';

  @override
  String get invalidEmail => 'Kérjük, adj meg egy érvényes e-mail címet.';

  @override
  String get enterPassword => 'Kérjük, add meg a jelszavadat.';

  @override
  String get passwordTooShort =>
      'A jelszónak legalább 8 karakter hosszúnak kell lennie.';

  @override
  String get confirmYourPassword => 'Kérjük, erősítsd meg a jelszavadat.';

  @override
  String get passwordsDoNotMatch => 'A két jelszó nem egyezik.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Már létezik egy fiók ezzel az e-mail címmel.';

  @override
  String get authErrorInvalidEmail =>
      'Kérjük, adjon meg egy érvényes e-mail címet.';

  @override
  String get authErrorWeakPassword => 'A jelszava túl gyenge.';

  @override
  String get authErrorInvalidCredentials => 'Helytelen e-mail cím vagy jelszó.';

  @override
  String get authErrorTooManyRequests =>
      'Túl sok próbálkozás. Kérjük, próbálja újra később.';

  @override
  String get authErrorNetworkError =>
      'Hálózati hiba. Kérjük, ellenőrizze a kapcsolatát.';

  @override
  String get authErrorUnknown => 'Valami hiba történt. Kérjük, próbálja újra.';
}
