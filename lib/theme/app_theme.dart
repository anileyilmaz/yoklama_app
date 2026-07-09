import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Web panelinin (`public/style.css`) kurumsal lacivert/altın kimliğiyle birebir
/// aynı renk token'ları — iki istemcinin aynı markayı taşıması için.
class AppColors {
  const AppColors._();

  static const primary = Color(0xff163a63);
  static const primaryDark = Color(0xff0e2848);
  static const primarySoft = Color(0xffe7edf6);
  static const accent = Color(0xffb08a2e);
  static const surface = Color(0xfff4f6f9);
  static const card = Color(0xffffffff);
  static const line = Color(0xffe2e7ee);
  static const text = Color(0xff1b2433);
  static const muted = Color(0xff5b6472);
  static const dark = Color(0xff10151d);
  static const danger = Color(0xffb3271f);
  static const darkSurface = Color(0xff0d141d);
  static const darkCard = Color(0xff141d29);
  static const darkLine = Color(0xff243244);
  static const darkText = Color(0xffeef2f7);
  static const darkMuted = Color(0xff97a3b3);
  static const darkPrimarySoft = Color(0xff1c2c40);

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

  static Color primarySoftOf(BuildContext context) =>
      isDark(context) ? darkPrimarySoft : primarySoft;

  static Color dangerSoftOf(BuildContext context) =>
      isDark(context) ? const Color(0xff3a1e1c) : const Color(0xfffbe9e7);

  static Color accentSoftOf(BuildContext context) =>
      isDark(context) ? const Color(0xff33290f) : const Color(0xfff6efdd);

  /// Lacivert (`primary`) koyu zeminde neredeyse hiç kontrast vermiyor — marka
  /// vurgusu gereken ikon/metin/buton gibi yerlerde bunun yerine bunu kullan:
  /// koyu modda mat altın, açık modda lacivert.
  static Color brandOf(BuildContext context) =>
      isDark(context) ? accent : primary;

  /// `brandOf` zemin rengi olarak kullanıldığında üstüne gelecek metin/ikon
  /// rengi — altın zemin açık metinle yeterli kontrast vermediği için koyu
  /// lacivert, lacivert zeminde ise beyaz.
  static Color onBrandOf(BuildContext context) =>
      isDark(context) ? primaryDark : Colors.white;
}

/// Web panelinin `--radius`/`--radius-sm` değerleriyle aynı hizada, tek yerden
/// yönetilen köşe yarıçapları.
class AppRadius {
  const AppRadius._();

  static const card = 14.0;
  static const control = 10.0;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    );
    final base = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: base
          .copyWith(
            headlineLarge: base.headlineLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: base.headlineMedium?.copyWith(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: base.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: base.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
            bodyMedium: base.bodyMedium?.copyWith(fontSize: 13, height: 1.35),
          )
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.line),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.line),
        ),
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
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: base
          .copyWith(
            headlineLarge: base.headlineLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: base.headlineMedium?.copyWith(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: base.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: base.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
            bodyMedium: base.bodyMedium?.copyWith(fontSize: 13, height: 1.35),
          )
          .apply(
            bodyColor: AppColors.darkText,
            displayColor: AppColors.darkText,
          ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.darkMuted),
        prefixIconColor: AppColors.darkMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.darkLine),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.darkLine),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.darkPrimarySoft,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          selectedForegroundColor: AppColors.darkText,
          selectedBackgroundColor: AppColors.darkPrimarySoft,
          side: const BorderSide(color: AppColors.darkLine),
        ),
      ),
    );
  }
}
