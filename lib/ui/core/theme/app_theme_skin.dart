import 'package:flutter/material.dart';

class AppThemeSkin {
  final String id;
  final String name;
  final Color bgGradientStart;
  final Color bgGradientMiddle;
  final Color bgGradientEnd;
  final Color cardBg;
  final Color cardBorder;
  final Color primaryAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceDark;
  final Color shadowColor;
  final Brightness brightness;

  const AppThemeSkin({
    required this.id,
    required this.name,
    required this.bgGradientStart,
    required this.bgGradientMiddle,
    required this.bgGradientEnd,
    required this.cardBg,
    required this.cardBorder,
    required this.primaryAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceDark,
    required this.shadowColor,
    this.brightness = Brightness.dark,
  });

  static const AppThemeSkin darkSkin = AppThemeSkin(
    id: 'dark',
    name: 'Dark',
    bgGradientStart: Color(0xFF28282B),
    bgGradientMiddle: Color(0xFF1D1D1F),
    bgGradientEnd: Color(0xFF141416),
    cardBg: Color(0xFF2C2C2E),
    cardBorder: Color(0xFF3A3A3C),
    primaryAccent: Color(0xFFFFB703),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFF8E8E93),
    surfaceDark: Color(0xFF1D1D1F),
    shadowColor: Color(0x66000000),
    brightness: Brightness.dark,
  );

  static const AppThemeSkin lightSkin = AppThemeSkin(
    id: 'light',
    name: 'Light',
    bgGradientStart: Color(0xFFFFF8F0),
    bgGradientMiddle: Color(0xFFFDECDD),
    bgGradientEnd: Color(0xFFF8DEC8),
    cardBg: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFEAD5C3),
    primaryAccent: Color(0xFFFF4B68),
    textPrimary: Color(0xFF2E2421),
    textSecondary: Color(0xFF88736B),
    surfaceDark: Color(0xFFFDF0E4),
    shadowColor: Color(0x184A2210),
    brightness: Brightness.light,
  );

  static const List<AppThemeSkin> allSkins = [
    darkSkin,
    lightSkin,
  ];

  static AppThemeSkin getSkin(String? themeId, [Brightness? platformBrightness]) {
    if (themeId == 'system') {
      return platformBrightness == Brightness.light ? lightSkin : darkSkin;
    }
    if (themeId == 'light') {
      return lightSkin;
    }
    return darkSkin;
  }
}
