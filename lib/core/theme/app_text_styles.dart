import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );

  static const TextStyle prayerName = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle timerLarge = TextStyle(
    fontSize: 44, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -2, height: 1.1,
  );

  static const TextStyle prayerTime = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12, color: AppColors.textSecondary,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 1.0,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
  );
}