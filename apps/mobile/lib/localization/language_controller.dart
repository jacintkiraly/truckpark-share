import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  LanguageController();

  static const _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  String get languageCode => _locale.languageCode;

  Locale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();

    final savedLanguageCode =
        preferences.getString(_languageKey);

    debugPrint(
      'LANGUAGE STORAGE: saved value = $savedLanguageCode',
    );

    if (savedLanguageCode == null ||
        savedLanguageCode.isEmpty) {
      debugPrint(
        'LANGUAGE STORAGE: no saved language, using English',
      );
      return;
    }

    _locale = Locale(savedLanguageCode);

    debugPrint(
      'LANGUAGE STORAGE: loaded $savedLanguageCode',
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _languageKey,
      languageCode,
    );

    final savedValue =
        preferences.getString(_languageKey);

    debugPrint(
      'LANGUAGE STORAGE: saved $languageCode',
    );

    debugPrint(
      'LANGUAGE STORAGE: verification = $savedValue',
    );

    _locale = Locale(languageCode);

    debugPrint(
      'LANGUAGE: current locale = $_locale',
    );

    notifyListeners();
  }
}