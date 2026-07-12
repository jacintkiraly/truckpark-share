import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../localization/generated/app_localizations.dart';

import '../features/welcome/welcome_screen.dart';

import 'theme.dart';

class TruckParkShareApp extends StatelessWidget {
  const TruckParkShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  onGenerateTitle: (context) =>
      AppLocalizations.of(context)!.appTitle,

  debugShowCheckedModeBanner: false,

  theme: TPSTheme.light(),

  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  supportedLocales: const [
    Locale('en'),
    Locale('hu'),
  ],

  home: const WelcomeScreen(),
);
  }
}