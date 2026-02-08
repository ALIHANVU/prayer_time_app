import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentLight,
      surface: AppColors.backgroundDark,
      onSurface: AppColors.textPrimaryDark,
    ),
  );
}