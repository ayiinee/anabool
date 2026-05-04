import 'package:flutter/material.dart';

class AnaboolColors {
  const AnaboolColors._();

  static const ink = Color(0xFF111111);
  static const muted = Color(0xFFA8A29E);
  static const canvas = Color(0xFFFFF1EB);
  static const surface = Color(0xFFFFFFFF);
  static const header = Color(0xFFFFAA61);
  static const peach = Color(0xFFFFDCCB);
  static const brown = Color(0xFFA64700);
  static const brownDark = Color(0xFF7A3400);
  static const brownSoft = Color(0xFFE8A766);
  static const orange = header;
  static const orangeDark = brown;
  static const orangeSoft = peach;
  static const rose = Color(0xFFFFE3E9);
  static const red = Color(0xFFD84055);
  static const green = Color(0xFF3F8F5B);
  static const earth = Color(0xFF6B8A52);
  static const border = Color(0xFFE6B49C);
  static const divider = Color(0xFFFFFFFF);
  static const shadow = Color(0x26000000);
}

class AnaboolTheme {
  const AnaboolTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AnaboolColors.orange,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: AnaboolColors.brown,
        secondary: AnaboolColors.header,
        surface: AnaboolColors.surface,
      ),
      scaffoldBackgroundColor: AnaboolColors.canvas,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AnaboolColors.ink,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          color: AnaboolColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: AnaboolColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        bodyLarge: TextStyle(
          color: AnaboolColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: AnaboolColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          color: AnaboolColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}
