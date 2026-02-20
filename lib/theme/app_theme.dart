import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFFFF6DB);
  static const creamDark = Color(0xFFFFE8A3);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFCA6400);
  static const orangeLight = Color(0xFFFFA952);
  static const gray = Color(0xFF6B7280);
  static const grayLight = Color(0xFFE5E7EB);
  static const black = Color(0xFF000000);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEF2F2);
  static const blue = Color(0xFF2563EB);
  static const greenLight = Color(0xFFDCFCE7);
  static const green = Color(0x00BF0D);
  static const surface = Color(0xFFF9FAFB);

  // Const-safe shadow colors (use in BoxShadow instead of Colors.blackXX)
  static const shadow06 = Color(0x0F000000); // ~6% black
  static const shadow08 = Color(0x14000000); // ~8% black
  static const shadow12 = Color(0x1F000000); // ~12% black
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.orange,
        secondary: AppColors.orangeLight,
        surface: AppColors.cream,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.figtreeTextTheme(),
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        titleTextStyle: GoogleFonts.figtree(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.shadow12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
