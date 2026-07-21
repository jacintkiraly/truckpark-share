import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../localization/generated/app_localizations.dart';

import '../features/onboarding/screens/welcome_screen.dart';

import 'theme.dart';
import '../localization/language_controller.dart';

class TruckParkShareApp extends StatefulWidget {
  const TruckParkShareApp({super.key});

  static final LanguageController languageController =
      LanguageController();

  @override
  State<TruckParkShareApp> createState() =>
      _TruckParkShareAppState();
}

class _TruckParkShareAppState extends State<TruckParkShareApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TruckParkShareApp.languageController,
      builder: (context, child) {
        return MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)!.appTitle,

          debugShowCheckedModeBanner: false,

          theme: TPSTheme.light(),

          locale: TruckParkShareApp.languageController.locale,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: AppLocalizations.supportedLocales,

          home: const WelcomeScreen(),
        );
      },
    );
  }
}