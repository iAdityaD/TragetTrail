import 'package:flutter/material.dart';

ThemeData buildAppTheme(
  Brightness brightness, {
  required Color seedColor,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    surface: brightness == Brightness.dark
        ? const Color(0xFF111827)
        : const Color(0xFFF8FAFC),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF020617)
        : const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardTheme(
      elevation: 0,
      color: brightness == Brightness.dark
          ? const Color(0xFF111827)
          : Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? const Color(0xFF1F2937)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
