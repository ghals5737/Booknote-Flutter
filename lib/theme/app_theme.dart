import 'package:flutter/material.dart';

/// design.json 기반 디자인 시스템
class AppTheme {
  // Primary Colors (design.json)
  static const Color brandBlue = Color(0xFF4F54E8);
  static const Color brandLightTint = Color(0xFFE8EAF6);
  static const Color brandHover = Color(0xFF3D42C9);

  // Neutral Colors (design.json)
  static const Color backgroundCanvas = Color(0xFFF7F8FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Typography Colors (design.json)
  static const Color headingDark = Color(0xFF111827);
  static const Color bodyMedium = Color(0xFF4B5563);
  static const Color metaLight = Color(0xFF9CA3AF);
  static const Color placeholder = Color(0xFFD1D5DB);

  // Legacy aliases for compatibility
  static const Color primaryColor = brandBlue;
  static const Color primaryLightColor = brandLightTint;
  static const Color backgroundColor = backgroundCanvas;
  static const Color cardColor = surfaceWhite;
  static const Color textPrimary = headingDark;
  static const Color textSecondary = bodyMedium;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBlue,
        brightness: Brightness.light,
        primary: brandBlue,
      ),
      scaffoldBackgroundColor: backgroundCanvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: headingDark),
        titleTextStyle: TextStyle(
          color: headingDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: headingDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: bodyMedium,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: metaLight,
          fontSize: 12,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: brandBlue,
        unselectedItemColor: metaLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Component-specific styles (design.json)
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      );

  static BoxShadow get statusCardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 4),
      );
}

