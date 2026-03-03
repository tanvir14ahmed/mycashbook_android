import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF8C00); // Deep Orange
  static const Color accentOrange = Color(0xFFFFA500); // Lighter Orange
  
  // Metallic Colors (Light)
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color silver = Color(0xFFC0C0C0);
  
  // Metallic Colors (Dark)
  static const Color gunmetal = Color(0xFF2C3539);
  static const Color titanium = Color(0xFF383E42);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        onPrimary: Colors.white,
        secondary: accentOrange,
        onSecondary: Colors.white,
        secondaryContainer: accentOrange.withOpacity(0.2),
        onSecondaryContainer: primaryOrange,
        surface: Colors.white,
        background: platinum,
      ),
      scaffoldBackgroundColor: platinum,
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: platinum,
        foregroundColor: gunmetal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryOrange),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        onPrimary: Colors.white,
        secondary: accentOrange,
        onSecondary: Colors.white,
        secondaryContainer: accentOrange.withOpacity(0.1),
        onSecondaryContainer: accentOrange,
        surface: gunmetal,
        background: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryOrange),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
