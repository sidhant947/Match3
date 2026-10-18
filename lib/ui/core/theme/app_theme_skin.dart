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
    bgGradientStart: Color(0xFF1C1E2B),
    bgGradientMiddle: Color(0xFF12131C),
    bgGradientEnd: Color(0xFF0B0C12),
    cardBg: Color(0xFF1E2130),
    cardBorder: Color(0xFF31364A),
    primaryAccent: Color(0xFFFFB703),
    textPrimary: Color(0xFFF1F3F9),
    textSecondary: Color(0xFF949BA8),
    surfaceDark: Color(0xFF151722),
    brightness: Brightness.dark,
  );

  static const AppThemeSkin lightSkin = AppThemeSkin(
    id: 'light',
    name: 'Light',
    bgGradientStart: Color(0xFFF8FAFC),
    bgGradientMiddle: Color(0xFFEDF2F7),
    bgGradientEnd: Color(0xFFE2E8F0),
    cardBg: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFCBD5E1),
    primaryAccent: Color(0xFFEA580C),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    surfaceDark: Color(0xFFF1F5F9),
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
