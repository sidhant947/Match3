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

  static const List<AppThemeSkin> allSkins = [
    AppThemeSkin(
      id: 'dark_charcoal',
      name: 'Midnight Charcoal',
      bgGradientStart: Color(0xFF222222),
      bgGradientMiddle: Color(0xFF161616),
      bgGradientEnd: Color(0xFF0F0F0F),
      cardBg: Color(0xFF222222),
      cardBorder: Color(0xFF383838),
      primaryAccent: Color(0xFFFFCE31),
      textPrimary: Colors.white,
      textSecondary: Color(0xFFB0B0B0),
      surfaceDark: Color(0xFF2E2E2E),
      brightness: Brightness.dark,
    ),
    AppThemeSkin(
      id: 'pastel_rose',
      name: 'Pastel Rose',
      bgGradientStart: Color(0xFFFFF0F5),
      bgGradientMiddle: Color(0xFFFFE4E1),
      bgGradientEnd: Color(0xFFFFD1DC),
      cardBg: Color(0xFFFFF8F9),
      cardBorder: Color(0xFFF4C2C2),
      primaryAccent: Color(0xFFE86A92),
      textPrimary: Color(0xFF4A2E35),
      textSecondary: Color(0xFF8C5F6B),
      surfaceDark: Color(0xFFFFE8EC),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_lavender',
      name: 'Pastel Lavender',
      bgGradientStart: Color(0xFFF3E8FF),
      bgGradientMiddle: Color(0xFFE9D5FF),
      bgGradientEnd: Color(0xFFDDD6FE),
      cardBg: Color(0xFFFAF5FF),
      cardBorder: Color(0xFFD8B4FE),
      primaryAccent: Color(0xFF9333EA),
      textPrimary: Color(0xFF3B1F5E),
      textSecondary: Color(0xFF6B4C9A),
      surfaceDark: Color(0xFFF0E5FF),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_mint',
      name: 'Pastel Mint',
      bgGradientStart: Color(0xFFE6F4F1),
      bgGradientMiddle: Color(0xFFD0EBE5),
      bgGradientEnd: Color(0xFFBBE2D8),
      cardBg: Color(0xFFF4FAF8),
      cardBorder: Color(0xFF9CDBCF),
      primaryAccent: Color(0xFF2D9C88),
      textPrimary: Color(0xFF1E423B),
      textSecondary: Color(0xFF4F7A71),
      surfaceDark: Color(0xFFDCF2EC),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_peach',
      name: 'Pastel Peach',
      bgGradientStart: Color(0xFFFFF3EB),
      bgGradientMiddle: Color(0xFFFFE6D5),
      bgGradientEnd: Color(0xFFFFD4BC),
      cardBg: Color(0xFFFFFAF7),
      cardBorder: Color(0xFFFCD0B8),
      primaryAccent: Color(0xFFF07848),
      textPrimary: Color(0xFF4E2616),
      textSecondary: Color(0xFF85503B),
      surfaceDark: Color(0xFFFFEFE6),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_sky',
      name: 'Pastel Sky',
      bgGradientStart: Color(0xFFEBF5FF),
      bgGradientMiddle: Color(0xFFD6E9FE),
      bgGradientEnd: Color(0xFFBEDBFE),
      cardBg: Color(0xFFF8FAFC),
      cardBorder: Color(0xFFA5F3FC),
      primaryAccent: Color(0xFF2563EB),
      textPrimary: Color(0xFF1E3A8A),
      textSecondary: Color(0xFF475569),
      surfaceDark: Color(0xFFE0F2FE),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_matcha',
      name: 'Pastel Matcha',
      bgGradientStart: Color(0xFFF2F7ED),
      bgGradientMiddle: Color(0xFFE2EFE0),
      bgGradientEnd: Color(0xFFCFE4CC),
      cardBg: Color(0xFFF8FCF6),
      cardBorder: Color(0xFFBBE4B4),
      primaryAccent: Color(0xFF5B9E4C),
      textPrimary: Color(0xFF24421E),
      textSecondary: Color(0xFF53734C),
      surfaceDark: Color(0xFFE6F3E3),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_sunshine',
      name: 'Pastel Sunshine',
      bgGradientStart: Color(0xFFFFFBEB),
      bgGradientMiddle: Color(0xFFFEF3C7),
      bgGradientEnd: Color(0xFFFDE68A),
      cardBg: Color(0xFFFFFFF7),
      cardBorder: Color(0xFFFDE047),
      primaryAccent: Color(0xFFD97706),
      textPrimary: Color(0xFF451A03),
      textSecondary: Color(0xFF78350F),
      surfaceDark: Color(0xFFFEF9C3),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_bubblegum',
      name: 'Cotton Candy',
      bgGradientStart: Color(0xFFFDF2F8),
      bgGradientMiddle: Color(0xFFFCE7F3),
      bgGradientEnd: Color(0xFFFBCFE8),
      cardBg: Color(0xFFFFF7ED),
      cardBorder: Color(0xFFF9A8D4),
      primaryAccent: Color(0xFFDB2777),
      textPrimary: Color(0xFF500724),
      textSecondary: Color(0xFF831843),
      surfaceDark: Color(0xFFFDE8E8),
      brightness: Brightness.light,
    ),
    AppThemeSkin(
      id: 'pastel_twilight',
      name: 'Periwinkle Dusk',
      bgGradientStart: Color(0xFFEEF2FF),
      bgGradientMiddle: Color(0xFFE0E7FF),
      bgGradientEnd: Color(0xFFC7D2FE),
      cardBg: Color(0xFFF8FAFC),
      cardBorder: Color(0xFFC7D2FE),
      primaryAccent: Color(0xFF4F46E5),
      textPrimary: Color(0xFF1E1B4B),
      textSecondary: Color(0xFF4338CA),
      surfaceDark: Color(0xFFE0E7FF),
      brightness: Brightness.light,
    ),
  ];

  static AppThemeSkin getSkin(String? themeId) {
    return allSkins.firstWhere(
      (s) => s.id == themeId,
      orElse: () => allSkins.first,
    );
  }
}
