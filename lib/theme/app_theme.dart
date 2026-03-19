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
  static const green = Color(0xFF16A34A);
  static const surface = Color(0xFFF9FAFB);

  // Dark Mode specific colors
  static const darkSurface = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFE1E1E1);
  static const darkGray = Color(0xFF333333);

  static const shadow06 = Color(0x0F000000);
  static const shadow08 = Color(0x14000000);
  static const shadow12 = Color(0x1F000000);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        brightness: Brightness.light,
        primary: AppColors.orange,
        secondary: AppColors.orangeLight,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.figtreeTextTheme().apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
      ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
