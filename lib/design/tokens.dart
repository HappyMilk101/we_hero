import 'package:flutter/material.dart';

abstract final class HeroColors {
  static const navy = Color(0xFF17233C);
  static const yellow = Color(0xFFFFC857);
  static const mint = Color(0xFF8ED8C5);
  static const coral = Color(0xFFFF7D6E);
  static const background = Color(0xFFF7F9FC);
  static const secondaryText = Color(0xFF667085);
}

abstract final class HeroSpacing {
  static const xs = 8.0, sm = 12.0, md = 16.0, lg = 20.0, xl = 28.0;
}

abstract final class HeroRadius {
  static const small = 12.0, medium = 16.0, large = 24.0, card = 28.0;
}

abstract final class HeroElevation {
  static const card = 0.0;
}

abstract final class HeroMotion {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);
}

ThemeData heroTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: HeroColors.background,
  colorScheme: ColorScheme.fromSeed(seedColor: HeroColors.navy),
  fontFamily: 'Earthcore Dream',
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: HeroColors.navy,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: HeroColors.navy,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: HeroColors.navy),
    bodyMedium: TextStyle(fontSize: 14, color: HeroColors.secondaryText),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HeroRadius.medium),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    height: 72,
    backgroundColor: Colors.white,
    indicatorColor: HeroColors.mint,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      backgroundColor: HeroColors.yellow,
      foregroundColor: HeroColors.navy,
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HeroRadius.medium),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(44, 48),
      foregroundColor: HeroColors.navy,
      side: const BorderSide(color: HeroColors.navy),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HeroRadius.medium),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: HeroColors.navy,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: HeroColors.mint,
    labelStyle: const TextStyle(
      color: HeroColors.navy,
      fontWeight: FontWeight.w700,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    side: BorderSide.none,
  ),
);
