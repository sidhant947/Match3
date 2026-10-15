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
    this.brightness = Brightness.dark,
  });

  static const AppThemeSkin darkSkin = AppThemeSkin(
    id: 'dark',
    name: 'Dark',
    bgGradientStart: Color(0xFF000000),
    bgGradientMiddle: Color(0xFF000000),
    bgGradientEnd: Color(0xFF000000),
    cardBg: Color(0xFF000000),
    cardBorder: Color(0xFFFFFFFF),
    primaryAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF000000),
    brightness: Brightness.dark,
  );

  static const AppThemeSkin lightSkin = AppThemeSkin(
    id: 'light',
    name: 'Light',
    bgGradientStart: Color(0xFFFFFFFF),
    bgGradientMiddle: Color(0xFFFFFFFF),
    bgGradientEnd: Color(0xFFFFFFFF),
    cardBg: Color(0xFFFFFFFF),
    cardBorder: Color(0xFF000000),
    primaryAccent: Color(0xFF000000),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF000000),
    surfaceDark: Color(0xFFFFFFFF),
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
