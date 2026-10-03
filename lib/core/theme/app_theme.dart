import 'package:flutter/material.dart';

class AppTheme {
  static const lime = Color(0xFFD4FF1A);
  static const background = Color(0xFF08080A);
  static const surface = Color(0xFF151519);
  static const surfaceAlt = Color(0xFF202027);

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(seedColor: lime, brightness: Brightness.dark)
            .copyWith(
      primary: lime,
      onPrimary: Colors.black,
      surface: background,
      onSurface: const Color(0xFFF4F4F0),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      appBarTheme: const AppBarTheme(backgroundColor: background, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: lime, width: 1.2)),
        hintStyle: TextStyle(color: Colors.white54),
      ),
    );
  }
}
