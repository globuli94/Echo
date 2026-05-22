import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color electricBlue = Color(0xFF129CFF);
  static const Color neonPurple = Color(0xFF7B2CFF);
  static const Color vibrantMagenta = Color(0xFFFF1FBF);

  // Background Colors
  static const Color deepNavy = Color(0xFF0B1020);
  static const Color darkPurple = Color(0xFF16132B);
  static const Color softDarkGray = Color(0xFF1E1E2E);

  // Text Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFB8B8C7);
  static const Color coolGray = Color(0xFF7D7D93);

  // UI Accent Colors
  static const Color hotPink = Color(0xFFFF4DA6);
  static const Color neonGreen = Color(0xFF32FF9D);
  static const Color brightCyan = Color(0xFF34D5FF);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepNavy,
        colorScheme: const ColorScheme.dark(
          primary: electricBlue,
          secondary: neonPurple,
          tertiary: vibrantMagenta,
          surface: softDarkGray,
          onPrimary: white,
          onSecondary: white,
          onSurface: white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: white),
          bodyMedium: TextStyle(color: lightGray),
          bodySmall: TextStyle(color: coolGray),
        ),
        cardTheme: const CardThemeData(
          color: softDarkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: darkPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: coolGray),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricBlue,
            foregroundColor: white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        useMaterial3: true,
      );
}
