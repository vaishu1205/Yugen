import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Japanese-inspired colors
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color deepRed = Color(0xFFDC143C);
  static const Color oceanBlue = Color(0xFF1E3A8A);
  static const Color mintGreen = Color(0xFF10B981);
  static const Color warmGold = Color(0xFFF59E0B);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color softGray = Color(0xFFF3F4F6);
  static const Color darkGray = Color(0xFF374151);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: oceanBlue,
    scaffoldBackgroundColor: Colors.white,

    // Google Fonts - automatically downloads and caches!
    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSansJp(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      displayMedium: GoogleFonts.notoSansJp(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      headlineLarge: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      titleLarge: GoogleFonts.notoSansJp(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: darkGray,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkGray,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkGray,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkGray,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}