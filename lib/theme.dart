import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lion-inspired dark theme: near-black warm surfaces, a gold accent, and a
/// condensed athletic display face for big numbers and titles.
class LionTheme {
  LionTheme._();

  static const Color gold = Color(0xFFF2B01E);
  static const Color goldDeep = Color(0xFFDD7B12);
  static const Color background = Color(0xFF0C0B08);
  static const Color surface = Color(0xFF16140E);
  static const Color surfaceHigh = Color(0xFF201C13);
  static const Color outline = Color(0xFF39331F);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7C64B), Color(0xFFF2B01E), Color(0xFFDD7B12)],
  );

  static const LinearGradient restGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2E3D), Color(0xFF1B1E2A)],
  );

  /// Display face for hero numbers and section titles.
  static TextStyle display({double size = 28, Color? color}) =>
      GoogleFonts.anton(
        fontSize: size,
        color: color,
        letterSpacing: 0.5,
      );

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      surface: surface,
    ).copyWith(
      primary: gold,
      onPrimary: const Color(0xFF221800),
      primaryContainer: const Color(0xFF3D2E00),
      onPrimaryContainer: const Color(0xFFFFDF9E),
      surfaceContainerHighest: surfaceHigh,
      outlineVariant: outline,
    );

    final baseText = ThemeData(brightness: Brightness.dark).textTheme;
    final textTheme = GoogleFonts.interTextTheme(baseText).copyWith(
      headlineMedium: GoogleFonts.anton(
          textStyle: baseText.headlineMedium, letterSpacing: 0.5),
      titleLarge: GoogleFonts.inter(
          textStyle: baseText.titleLarge, fontWeight: FontWeight.w800),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF262115)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF39331F)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF12100B),
        indicatorColor: gold.withValues(alpha: 0.22),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
