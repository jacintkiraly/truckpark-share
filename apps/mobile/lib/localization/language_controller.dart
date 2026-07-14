import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  LanguageController();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

 void setLanguage(String languageCode) {
  _locale = Locale(languageCode);

  debugPrint('Language changed to: $languageCode');
  debugPrint('Current locale: $_locale');

  notifyListeners();
}
}