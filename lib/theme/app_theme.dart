import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Market / taze ürün teması: yeşil + sıcak turuncu.
///
/// Ekranlar renkleri doğrudan buradan değil, [AppPalette] üzerinden okur;
/// böylece aynı widget açık ve koyu modda doğru kontrastı yakalar.
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

/// Ekranların kullandığı anlamsal renkler.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.green,
    required this.greenDeep,
    required this.greenSoft,
    required this.onGreenSoft,
    required this.orange,
    required this.orangeSoft,
    required this.danger,
    required this.best,
    required this.onAccent,
  });

  static const light = AppPalette(
    background: AppColors.cream,
    surface: AppColors.surface,
    ink: AppColors.ink,
    inkMuted: AppColors.inkMuted,
    border: AppColors.border,
    green: AppColors.green,
    greenDeep: AppColors.greenDark,
    greenSoft: AppColors.greenSoft,
    onGreenSoft: AppColors.greenDark,
    orange: AppColors.orange,
    orangeSoft: AppColors.orangeSoft,
    danger: AppColors.danger,
    best: AppColors.best,
    onAccent: Colors.white,
  );

  static const dark = AppPalette(
    background: Color(0xFF12160F),
    surface: Color(0xFF1B211C),
    ink: Color(0xFFECF1EC),
    inkMuted: Color(0xFF9BAAA0),
    border: Color(0xFF2E3A31),
    green: Color(0xFF2E9C64),
    greenDeep: Color(0xFF1A6440),
    greenSoft: Color(0xFF17301F),
    onGreenSoft: Color(0xFF6FD6A0),
    orange: Color(0xFFFF8A5B),
    orangeSoft: Color(0xFF33211A),
    danger: Color(0xFFFF6B5B),
    best: Color(0xFF3FD18C),
    onAccent: Colors.white,
  );

  final Color background;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color border;

  /// Ana vurgu dolgusu (buton, kart gradyanı başlangıcı).
  final Color green;

  /// Gradyan bitişi — [green] tonunun koyusu.
  final Color greenDeep;

  /// Yumuşak yeşil zemin (rozet, ikon kutusu).
  final Color greenSoft;

  /// [greenSoft] üzerindeki metin ve ikon rengi.
  final Color onGreenSoft;

  final Color orange;
  final Color orangeSoft;
  final Color danger;
  final Color best;

  /// Dolu vurgu zeminleri üzerindeki metin rengi.
  final Color onAccent;

  /// Vurgu kartlarının gradyanı.
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [green, greenDeep],
      );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? inkMuted,
    Color? border,
    Color? green,
    Color? greenDeep,
    Color? greenSoft,
    Color? onGreenSoft,
    Color? orange,
    Color? orangeSoft,
    Color? danger,
    Color? best,
    Color? onAccent,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      border: border ?? this.border,
      green: green ?? this.green,
      greenDeep: greenDeep ?? this.greenDeep,
      greenSoft: greenSoft ?? this.greenSoft,
      onGreenSoft: onGreenSoft ?? this.onGreenSoft,
      orange: orange ?? this.orange,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      danger: danger ?? this.danger,
      best: best ?? this.best,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenDeep: Color.lerp(greenDeep, other.greenDeep, t)!,
      greenSoft: Color.lerp(greenSoft, other.greenSoft, t)!,
      onGreenSoft: Color.lerp(onGreenSoft, other.onGreenSoft, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      orangeSoft: Color.lerp(orangeSoft, other.orangeSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      best: Color.lerp(best, other.best, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: palette.green,
        onPrimary: palette.onAccent,
        secondary: palette.orange,
        surface: palette.surface,
        onSurface: palette.ink,
        error: palette.danger,
        brightness: brightness,
      ),
    );

    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: palette.ink,
      displayColor: palette.ink,
    );

    return base.copyWith(
      extensions: [palette],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.ink,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: palette.ink,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.green,
          foregroundColor: palette.onAccent,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.onGreenSoft),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.ink,
        contentTextStyle: GoogleFonts.manrope(
          color: palette.background,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.green, width: 1.6),
        ),
        hintStyle: GoogleFonts.manrope(color: palette.inkMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.greenSoft,
        selectedColor: palette.green,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: palette.onGreenSoft,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: palette.onAccent,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.greenSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? palette.onGreenSoft : palette.inkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? palette.onGreenSoft : palette.inkMuted,
          );
        }),
      ),
    );
  }
}
