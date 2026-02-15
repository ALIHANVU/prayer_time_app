import 'package:flutter/material.dart';
import '../../../core/utils/prayer_calculator.dart';

/// Больше не используется — заменён градиентной шкалой в HeroCard
class ZonedProgressPainter extends CustomPainter {
  final double fadilaFraction;
  final double permissibleFraction;
  final double progress;
  final PrayerZone zone;
  final bool isDark;

  ZonedProgressPainter({
    required this.fadilaFraction,
    required this.permissibleFraction,
    required this.progress,
    required this.zone,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(ZonedProgressPainter old) => false;
}