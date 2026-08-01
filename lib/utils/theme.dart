import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nothing OS design system — monochrome black/white + Nothing Red accent.
/// Industrial, terminal-like, dot matrix aesthetic.
class HydraTheme {
  // ── Surfaces (pure black OLED-like) ─────────────────────────
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceLight = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF161616);

  // ── Borders & dividers (thin 1px lines) ─────────────────────
  static const Color border = Color(0xFF1A1A1A);
  static const Color borderStrong = Color(0xFF222222);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF808080);
  static const Color textTertiary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF333333);

  // ── Accent — Nothing Red, used sparingly ────────────────────
  static const Color accent = Color(0xFFFF2D2D);
  static const Color accentDim = Color(0xFFB81E1E);

  // ── Semantic ────────────────────────────────────────────────
  static const Color debt = Color(0xFFFF2D2D);
  static const Color goal = Color(0xFFFFFFFF);

  // ── Typography (Space Grotesk + Space Mono via google_fonts) ──
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: 4.0,
        color: textPrimary,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.5,
        color: textPrimary,
      );

  static TextStyle get headline => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: textPrimary,
      );

  static TextStyle get titleUpper => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.8,
        color: textSecondary,
      );

  static TextStyle get body => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodySecondary => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: textSecondary,
      );

  static TextStyle get dataLarge => GoogleFonts.spaceMono(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.0,
      );

  static TextStyle get dataMedium => GoogleFonts.spaceMono(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.0,
      );

  static TextStyle get dataSmall => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.0,
      );

  static TextStyle get dataRed => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: accent,
        letterSpacing: 1.2,
      );

  static TextStyle get dataRedLarge => GoogleFonts.spaceMono(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: accent,
        letterSpacing: 1.2,
      );

  // ── ThemeData ───────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        canvasColor: background,
        colorScheme: const ColorScheme.dark(
          primary: textPrimary,
          onPrimary: background,
          secondary: accent,
          onSecondary: background,
          surface: surface,
          onSurface: textPrimary,
          error: accent,
          onError: background,
        ),
        dividerColor: border,
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: textPrimary, size: 20),
          titleTextStyle: headline,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 20,
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
          space: 1,
        ),
        textTheme: TextTheme(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          headlineSmall: headline,
          titleSmall: titleUpper,
          bodyLarge: body,
          bodyMedium: body,
          bodySmall: bodySecondary,
          labelSmall: label,
        ),
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: border, width: 1),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: textPrimary,
            side: const BorderSide(color: textPrimary, width: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
              color: textPrimary,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: const BorderSide(color: borderStrong, width: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.8,
              color: textPrimary,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: textPrimary,
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: textPrimary,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: borderStrong, width: 1),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: borderStrong, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: textPrimary, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          labelStyle: label,
          hintStyle: bodySecondary,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceElevated,
          contentTextStyle: body.copyWith(color: textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: borderStrong, width: 1),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: borderStrong, width: 1),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accent,
          linearTrackColor: border,
          circularTrackColor: border,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}

/// Reusable decorative widgets used across screens.
class NothingDecor {
  /// Thin horizontal hairline.
  static const Widget hairline = Divider(
    height: 1,
    thickness: 1,
    color: HydraTheme.border,
  );

  static Widget hairlineWithLabel(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label.toUpperCase(), style: HydraTheme.label),
        const SizedBox(width: 12),
        const Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: HydraTheme.border,
          ),
        ),
      ],
    );
  }
}
