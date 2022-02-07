import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF337AB7),
        secondary: Colors.green,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF337AB7)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
      ),
    );
  }
}
