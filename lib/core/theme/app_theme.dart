import 'package:flutter/material.dart';

/// Colors and shapes copied from the SarmaxStream website so the app looks
/// like the same product.
class AppTheme {
  static const lime = Color(0xFFD1FF1A);
  static const purple = Color(0xFF8000FF);
  static const background = Color(0xFF08080A);
  static const surface = Color(0xFF0E0E11);
  static const surfaceAlt = Color(0xFF1D1D20);
  static const border = Color(0xFF222225);
  static const muted = Color(0xFFA1A1AA);
  static const radius = 12.0;

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(seedColor: lime, brightness: Brightness.dark)
            .copyWith(
      primary: lime,
      onPrimary: background,
      secondary: purple,
      surface: background,
      onSurface: Colors.white,
      outline: border,
    );
    const shape = BorderRadius.all(Radius.circular(radius));
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0),
      cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: shape, side: BorderSide(color: border))),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          indicatorColor: lime.withValues(alpha: .16),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? lime : muted)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: states.contains(WidgetState.selected)
                      ? Colors.white
                      : muted))),
      chipTheme: ChipThemeData(
          backgroundColor: surfaceAlt,
          side: const BorderSide(color: border),
          labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
          shape: const StadiumBorder()),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: background,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: const RoundedRectangleBorder(borderRadius: shape))),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
            borderRadius: shape, borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: shape, borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: shape, borderSide: BorderSide(color: lime, width: 1.2)),
        hintStyle: TextStyle(color: muted),
      ),
    );
  }
}
