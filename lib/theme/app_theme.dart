import 'package:flutter/material.dart';

/// design.json 기반 디자인 시스템 (Warm Minimalist Theme)
class AppTheme {
  // Brand Colors (design.json)
  static const Color brandPrimary = Color(0xFF4E4036); // primary
  static const Color brandPrimaryHover = Color(0xFF3A3029); // primaryHover
  static const Color brandAccent = Color(0xFFE6DCCA); // accent
  static const Color brandHighlight = Color(0xFFFF7F50); // highlight

  // Background Colors (design.json)
  static const Color backgroundCanvas = Color(0xFFF4F2F0); // appCanvas
  static const Color surfaceWhite = Color(0xFFFFFFFF); // surfacePrimary
  static const Color surfaceSecondary = Color(0xFFFAFAFA); // surfaceSecondary
  static const Color overlayDark = Color.fromRGBO(44, 38, 34, 0.6); // overlayDark

  // Border Colors (design.json)
  static const Color borderSubtle = Color(0xFFEAEAEA); // subtle
  static const Color borderFocus = Color(0xFF4E4036); // focus

  // Typography Colors (design.json)
  static const Color headingDark = Color(0xFF2C2622); // heading
  static const Color bodyMedium = Color(0xFF4A4A4A); // body
  static const Color metaLight = Color(0xFF8C8C8C); // muted
  static const Color textInverse = Color(0xFFFFFFFF); // inverse

  // Status Colors (design.json)
  static const Color statusSuccess = Color(0xFF6B8E23); // success
  static const Color statusWarning = Color(0xFFDAA520); // warning

  // Legacy aliases for compatibility
  static const Color brandBlue = brandPrimary; // 기존 코드 호환성
  static const Color brandHover = brandPrimaryHover;
  static const Color brandLightTint = brandAccent;
  static const Color primaryColor = brandPrimary;
  static const Color primaryLightColor = brandAccent;
  static const Color backgroundColor = backgroundCanvas;
  static const Color cardColor = surfaceWhite;
  static const Color textPrimary = headingDark;
  static const Color textSecondary = bodyMedium;
  static const Color divider = borderSubtle;
  static const Color placeholder = metaLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPrimary,
        brightness: Brightness.light,
        primary: brandPrimary,
        onPrimary: textInverse,
        secondary: brandAccent,
        onSecondary: headingDark,
        error: Colors.red,
        surface: surfaceWhite,
        onSurface: headingDark,
      ),
      scaffoldBackgroundColor: backgroundCanvas,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundCanvas, // topBar backgroundColor
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: brandPrimary), // topBar textColor
        titleTextStyle: const TextStyle(
          color: brandPrimary, // topBar textColor
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pretendard', // body font
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // dashboardCard borderRadius
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: headingDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif KR', // headings font
        ),
        displayMedium: TextStyle(
          color: headingDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif KR',
        ),
        displaySmall: TextStyle(
          color: headingDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif KR',
        ),
        headlineMedium: TextStyle(
          color: headingDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif KR',
        ),
        titleLarge: TextStyle(
          color: headingDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif KR',
        ),
        titleMedium: TextStyle(
          color: headingDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard', // body font
        ),
        bodyLarge: TextStyle(
          color: bodyMedium,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Pretendard',
        ),
        bodyMedium: TextStyle(
          color: bodyMedium,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Pretendard',
        ),
        bodySmall: TextStyle(
          color: metaLight,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Pretendard',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary, // primary backgroundColor
          foregroundColor: textInverse, // primary textColor
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // primary borderRadius
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // primary padding
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPrimary,
          side: const BorderSide(color: borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite, // searchBar backgroundColor
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // searchBar borderRadius
          borderSide: const BorderSide(color: borderSubtle), // searchBar border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderFocus, width: 2),
        ),
        hintStyle: const TextStyle(
          color: metaLight, // placeholderColor
          fontFamily: 'Pretendard',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: brandPrimary,
        unselectedItemColor: metaLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: brandPrimary, // progressBar fillColor
        linearTrackColor: borderSubtle, // progressBar trackColor
      ),
    );
  }

  // Component-specific styles (design.json)
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.03), // dashboardCard boxShadow
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  static BoxShadow get bookCoverShadow => BoxShadow(
        color: Colors.black.withOpacity(0.15), // bookCover boxShadow
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow get statusCardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  // Border radius (design.json)
  static const double cardBorderRadius = 12.0; // dashboardCard borderRadius
  static const double buttonBorderRadius = 6.0; // primary borderRadius
  static const double inputBorderRadius = 8.0; // searchBar borderRadius
  static const double bookCoverBorderRadius = 4.0; // bookCover borderRadius
  static const double progressBarBorderRadius = 3.0; // progressBar borderRadius

  // Spacing (design.json)
  static const double cardPadding = 24.0; // dashboardCard padding
  static const double searchBarHeight = 48.0; // searchBar height
  static const double topBarHeight = 64.0; // topBar height
  static const double progressBarHeight = 6.0; // progressBar height
}

