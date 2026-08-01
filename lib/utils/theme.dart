import 'package:flutter/material.dart';

class HydraTheme {
  // Deep ocean blues with cyan accents — water aesthetic.
  static const Color primary = Color(0xFF00B4D8);
  static const Color primaryDark = Color(0xFF0077B6);
  static const Color surface = Color(0xFF0A1929);
  static const Color surfaceLight = Color(0xFF13283B);
  static const Color accent = Color(0xFF48CAE4);
  static const Color warning = Color(0xFFFFB703);
  static const Color danger = Color(0xFFEF476F);
  static const Color success = Color(0xFF06D6A0);
  static const Color textPrimary = Color(0xFFE8F1F8);
  static const Color textSecondary = Color(0xFF7A92A8);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: surface,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
}