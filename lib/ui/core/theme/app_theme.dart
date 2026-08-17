import 'package:flutter/material.dart';
import 'app_colors.dart';

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  static ThemeData get dark => ThemeData(
    fontFamily: 'BebasNeue',
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.charcoal,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: AppColors.headingDark,
        letterSpacing: 1.0,
      ),
      iconTheme: IconThemeData(color: AppColors.headingDark),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderCharcoal,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: -0.5),
      titleLarge: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: 0.5),
      titleMedium: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, letterSpacing: 0.5),
      bodyLarge: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontFamily: 'BebasNeue', color: AppColors.subtext, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'BebasNeue', color: AppColors.headingDark, fontWeight: FontWeight.bold),
    ),
  );
}
