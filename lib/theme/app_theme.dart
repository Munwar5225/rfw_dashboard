import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _secondary = Color(0xFF03DAC6);
  static const Color _background = Color(0xFF0F0E17);
  static const Color _surface = Color(0xFF1A1B2E);
  static const Color _surfaceVariant = Color(0xFF252640);
  static const Color _onSurface = Color(0xFFEFEFF4);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          secondary: _secondary,
          surface: _surface,
          onSurface: _onSurface,
        ),
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _onSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: _onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: _surfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: _onSurface,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: _onSurface),
          bodySmall: TextStyle(color: Color(0xFF9A9AB0)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceVariant,
          contentTextStyle: const TextStyle(color: _onSurface),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
