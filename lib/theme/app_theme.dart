import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF1C1C1E);
  static const Color accent = Color(0xFFFA2D48);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFF2C2C2E);
  static const Color elevated = Color(0xFF2C2C2E);
  static const Color playerBackground = Color(0xFF1A1A1A);
  static const Color sliderActive = Color(0xFFFA2D48);
  static const Color sliderInactive = Color(0xFF3A3A3C);
  static const Color navBar = Color(0xFF111111);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.card,
        onPrimary: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.accent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sliderActive,
        inactiveTrackColor: AppColors.sliderInactive,
        thumbColor: AppColors.textPrimary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        trackHeight: 3,
        overlayColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.4,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.3,
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.1,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
    );
  }
}
