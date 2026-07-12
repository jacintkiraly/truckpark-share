import 'package:flutter/material.dart';

import 'colors.dart';

class TPSTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: TPSColors.primary,
      ),

      scaffoldBackgroundColor: TPSColors.background,

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: TPSColors.background,
        foregroundColor: TPSColors.textPrimary,
      ),
    );
  }
}