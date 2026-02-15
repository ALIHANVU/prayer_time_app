import 'package:flutter/material.dart';

class AppColors {
  // ─── Акцент ───
  static const Color accent = Color(0xFF007AFF);
  static const Color accentLight = Color(0xFF5AC8FA);

  // ─── Зоны намаза ───
  static const Color fadila = Color(0xFF34C759);
  static const Color permissible = Color(0xFFFF9500);
  static const Color makruh = Color(0xFFFF3B30);
  static const Color missed = Color(0xFFC7C7CC);

  // ─── Фоны ───
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceSecondaryDark = Color(0xFF2C2C2E);

  // ─── Полупрозрачные карточки (frosted) ───
  static const Color frostedLight = Color(0xB8FFFFFF);
  static const Color frostedDark = Color(0xB81C1C1E);

  // ─── Текст ───
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF48484A);

  // ─── Разделители ───
  static const Color separator = Color(0x33000000);
  static const Color separatorDark = Color(0xFF38383A);

  // ─── Навбар (матовое стекло — плавающий iOS 26) ───
  static const Color navBarLight = Color(0xE6F9F9F9);  // ~90% opacity
  static const Color navBarDark = Color(0xE61C1C1E);

  // ─── Утилиты ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color ringTrack = Color(0xFFE5E5EA);
  static const Color ringTrackDark = Color(0xFF38383A);

  // ─── Радиусы iOS 26 ───
  static const double radiusS = 16.0;
  static const double radiusM = 22.0;
  static const double radiusL = 28.0;
  static const double radiusXL = 36.0;
}