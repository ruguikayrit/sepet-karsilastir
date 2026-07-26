import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Market / taze ürün teması: yeşil + sıcak turuncu.
class AppColors {
  static const green = Color(0xFF1F7A4D);
  static const greenDark = Color(0xFF145C38);
  static const greenSoft = Color(0xFFE8F5EE);
  static const orange = Color(0xFFE5672F);
  static const orangeSoft = Color(0xFFFFF1E8);
  static const cream = Color(0xFFF7F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A211C);
  static const inkMuted = Color(0xFF5C6B62);
  static const border = Color(0xFFD9E2DB);
  static const danger = Color(0xFFC0392B);
  static const best = Color(0xFF0E8F55);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        secondary: AppColors.orange,
        surface: AppColors.surface,
        error: AppColors.danger,
        brightness: Brightness.light,
      ),
    );

    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.6),
        ),
        hintStyle: GoogleFonts.manrope(color: AppColors.inkMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greenSoft,
        selectedColor: AppColors.green,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: AppColors.greenDark,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.greenSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.greenDark : AppColors.inkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.greenDark : AppColors.inkMuted,
          );
        }),
      ),
    );
  }
}
