import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF1F2527);
  static const inkStrong = Color(0xFF172023);
  static const muted = Color(0xFF615F59);
  static const mutedLight = Color(0xFF68665F);
  static const eyebrow = Color(0xFF6F6A62);
  static const teal = Color(0xFF0F766E);
  static const tealDark = Color(0xFF0F5E57);
  static const chipBg = Color(0xFFDFF0EA);
  static const criticalBg = Color(0xFFF1C7B8);
  static const criticalFg = Color(0xFF7B341E);
  static const highBg = Color(0xFFF6E0BA);
  static const highFg = Color(0xFF7B5B1D);
  static const normalBg = Color(0xFFDFEEE9);
  static const normalFg = Color(0xFF1C6C63);
  static const unreadBg = Color(0xFFF5DDD4);
  static const unreadFg = Color(0xFF9A4328);
  static const accentRust = Color(0xFFC75B39);
  static const panelBorder = Color(0x2A6E604F);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      surface: const Color(0xFFFFFDF7),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.latoTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.libreBaskerville(
        textStyle: base.textTheme.headlineLarge,
        color: AppColors.inkStrong,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.libreBaskerville(
        textStyle: base.textTheme.headlineMedium,
        color: AppColors.inkStrong,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.libreBaskerville(
        textStyle: base.textTheme.headlineSmall,
        color: AppColors.inkStrong,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.libreBaskerville(
        textStyle: base.textTheme.titleLarge,
        color: AppColors.inkStrong,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

BoxDecoration appBackgroundDecoration() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF6F1E7),
          Color(0xFFEBE2D4),
        ],
      ),
    );
