import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgDeep     = Color(0xFF0A0E1A);
  static const Color bgCard     = Color(0xFF111827);
  static const Color bgElevated = Color(0xFF1A2235);
  static const Color accent     = Color(0xFF00D4FF);
  static const Color accentGreen  = Color(0xFF00FF88);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color textPrimary  = Color(0xFFE2E8F0);
  static const Color textSecondary= Color(0xFF94A3B8);
  static const Color border       = Color(0xFF1E3A5F);
  static const Color success      = Color(0xFF00FF88);
  static const Color error        = Color(0xFFFF4444);
  static const Color warning      = Color(0xFFFFB800);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentGreen,
      surface: bgCard,
      error: error,
    ),
    textTheme: GoogleFonts.spaceMonoTextTheme(
      const TextTheme(
        bodyLarge:  TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgDeep,
      elevation: 0,
      titleTextStyle: GoogleFonts.orbitron(
        color: accent, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2),
      iconTheme: const IconThemeData(color: accent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgElevated,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 1.5)),
      labelStyle:
          GoogleFonts.spaceMono(color: textSecondary, fontSize: 13),
      hintStyle: GoogleFonts.spaceMono(
          color: textSecondary, fontSize: 12),
    ),
  );

  // Responsive helpers
  static bool isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < 600;

  static double hPad(BuildContext ctx) => isMobile(ctx) ? 16 : 24;
  static double cardRadius(BuildContext ctx) => isMobile(ctx) ? 10 : 14;
  static double titleSize(BuildContext ctx) => isMobile(ctx) ? 13 : 16;
  static double bodySize(BuildContext ctx) => isMobile(ctx) ? 11 : 13;
}
