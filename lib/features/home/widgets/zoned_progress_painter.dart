import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/prayer_calculator.dart';

/// Кольцо прогресса с зонами — чистый iOS стиль
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
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 8.0;
    const startAngle = -pi / 2;

    // Фон кольца
    final bgPaint = Paint()
      ..color = isDark ? AppColors.ringTrackDark : AppColors.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final totalAngle = 2 * pi;
    final fadilaAngle = fadilaFraction * totalAngle;
    final permAngle = permissibleFraction * totalAngle;
    final makruhAngle =
        (1.0 - fadilaFraction - permissibleFraction) * totalAngle;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Фадиля
    final fadilaPaint = Paint()
      ..color = AppColors.fadila
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, fadilaAngle, false, fadilaPaint);

    // Допустимо
    final permPaint = Paint()
      ..color = AppColors.permissible
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
        rect, startAngle + fadilaAngle, permAngle, false, permPaint);

    // Макрух
    final makruhPaint = Paint()
      ..color = AppColors.makruh
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle + fadilaAngle + permAngle, makruhAngle,
        false, makruhPaint);

    // Тонкие белые разделители
    final divPaint = Paint()
      ..color = isDark ? AppColors.backgroundDark : AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    void drawDivider(double angle) {
      final s = Offset(
        center.dx + (radius - strokeWidth / 2 - 1) * cos(angle),
        center.dy + (radius - strokeWidth / 2 - 1) * sin(angle),
      );
      final e = Offset(
        center.dx + (radius + strokeWidth / 2 + 1) * cos(angle),
        center.dy + (radius + strokeWidth / 2 + 1) * sin(angle),
      );
      canvas.drawLine(s, e, divPaint);
    }

    drawDivider(startAngle + fadilaAngle);
    drawDivider(startAngle + fadilaAngle + permAngle);

    // Точка прогресса
    if (progress > 0 && progress < 1) {
      final dotAngle = startAngle + progress * totalAngle;
      final dotCenter = Offset(
        center.dx + radius * cos(dotAngle),
        center.dy + radius * sin(dotAngle),
      );

      // Тень
      canvas.drawCircle(
        dotCenter,
        6,
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Белая точка
      canvas.drawCircle(dotCenter, 5, Paint()..color = Colors.white);

      // Обводка цветом зоны
      Color dotBorder;
      if (progress <= fadilaFraction) {
        dotBorder = AppColors.fadila;
      } else if (progress <= fadilaFraction + permissibleFraction) {
        dotBorder = AppColors.permissible;
      } else {
        dotBorder = AppColors.makruh;
      }
      canvas.drawCircle(
        dotCenter,
        5,
        Paint()
          ..color = dotBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(ZonedProgressPainter old) =>
      old.progress != progress ||
          old.fadilaFraction != fadilaFraction ||
          old.zone != zone ||
          old.isDark != isDark;
}