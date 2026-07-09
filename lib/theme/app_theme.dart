import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xff0f766e);
  static const primaryDark = Color(0xff0b5f58);
  static const accent = Color(0xff14b8a6);
  static const mint = Color(0xffccfbf1);
  static const surface = Color(0xfff8fafc);
  static const card = Color(0xffffffff);
  static const line = Color(0xffe5edf0);
  static const text = Color(0xff0f172a);
  static const muted = Color(0xff64748b);
  static const dark = Color(0xff111c24);
  static const danger = Color(0xffef4444);
  static const amber = Color(0xfff59e0b);
  static const darkSurface = Color(0xff0b1117);
  static const darkCard = Color(0xff121b24);
  static const darkLine = Color(0xff243241);
  static const darkText = Color(0xffeef6f7);
  static const darkMuted = Color(0xff9aa8b5);
  static const darkMint = Color(0xff123b37);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color cardOf(BuildContext context) =>
      isDark(context) ? darkCard : card;

  static Color lineOf(BuildContext context) =>
      isDark(context) ? darkLine : line;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkText : text;

  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkMuted : muted;

  static Color mintOf(BuildContext context) =>
      isDark(context) ? darkMint : mint;

  static Color dangerSoftOf(BuildContext context) =>
      isDark(context) ? const Color(0xff3f1d23) : const Color(0xffffe4e6);

  static Color amberSoftOf(BuildContext context) =>
      isDark(context) ? const Color(0xff3d2d13) : const Color(0xfffff7ed);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(fontSize: 13, height: 1.35),
      ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xfff4f7f8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.line),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      surface: AppColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      fontFamily: 'Poppins',
      textTheme:
          const TextTheme(
            headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            headlineMedium: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            bodyLarge: TextStyle(fontSize: 15, height: 1.45),
            bodyMedium: TextStyle(fontSize: 13, height: 1.35),
          ).apply(
            bodyColor: const Color(0xffeef6f7),
            displayColor: const Color(0xffeef6f7),
          ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xff0b1117),
        foregroundColor: Color(0xffeef6f7),
        titleTextStyle: TextStyle(
          color: Color(0xffeef6f7),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff121b24),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
        labelStyle: const TextStyle(color: Color(0xff9aa8b5)),
        prefixIconColor: const Color(0xff9aa8b5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: Color(0xff243241)),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xff121b24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xff121b24),
        indicatorColor: AppColors.darkMint,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          foregroundColor: const Color(0xffeef6f7),
          selectedForegroundColor: const Color(0xffeef6f7),
          selectedBackgroundColor: AppColors.darkMint,
          side: const BorderSide(color: Color(0xff243241)),
        ),
      ),
    );
  }
}
