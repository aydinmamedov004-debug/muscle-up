import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceLight = Color(0xFF262626);

  static const Color primary = Color(0xFFFF3B30);

  // Tinted background + matching foreground for icon chips (e.g. stat tiles).
  static const Color accentTint = Color(0xFF3A1412);
  static const Color accentSoft = Color(0xFFFFB3AD);

  static const Color text = Color(0xFFF4F4F4);
  static const Color secondaryText = Color(0xFFA0A0A0);
  static final Color divider = Colors.white.withValues(alpha: 0.14);

  // "Completed" affordance (e.g. finished workout days) — the app has no
  // other use for green, so this is the one deliberate spot of color.
  static const Color success = Color(0xFF34C759);

  // Streak celebration tokens — alpha-blended text variants and glow colors
  // with no existing equivalent (secondaryText is a solid gray, not the
  // white-alpha system this high-fidelity screen is built on).
  static final Color textMuted = text.withValues(alpha: 0.55);
  static final Color textFaint = text.withValues(alpha: 0.28);
  static const Color accentLightest = Color(0xFFFFE0DC);
  static const Color accentCoral = Color(0xFFFF7D72);
  static const Color glowDeep = Color(0xFF6B1611);
  static const Color glowDeepest = Color(0xFF430D0D);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    fontFamily: GoogleFonts.inter().fontFamily,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: surface,
    ),

    dividerColor: divider,

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),
    ),

    // Primary actions: accent-outlined, not filled — matches the redesign's
    // .btn-primary (transparent bg, accent border + text).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // Secondary actions: neutral-outlined, so they read as lower-priority
    // than the accent-outlined primary buttons above.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: divider),
        foregroundColor: text.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        },
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: surfaceLight,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: text,
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: text,
        fontSize: 25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        color: text,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: text,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: secondaryText,
        fontSize: 14,
      ),
    ),
  );
}
