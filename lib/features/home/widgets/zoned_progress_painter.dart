import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ZonedProgressPainter extends CustomPainter {
  final double progress;
  final double fadilaFraction;
  final double permissibleFraction;
  final double strokeWidth;

  ZonedProgressPainter({
    required this.progress,
    required this.fadilaFraction,
    required this.permissibleFraction,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;
    final fullCircle = 2 * pi;

    // Фон дорожки
    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    // Сектор Фадиля
    final fadilaAngle = fullCircle * fadilaFraction;
    canvas.drawArc(rect, startAngle, fadilaAngle, false, Paint()
      ..color = AppColors.fadila
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    // Сектор Допустимо
    final permAngle = fullCircle * permissibleFraction;
    canvas.drawArc(rect, startAngle + fadilaAngle, permAngle, false, Paint()
      ..color = AppColors.permissible.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt);

    // Сектор Макрух
    final makruhFraction = 1.0 - fadilaFraction - permissibleFraction;
    final makruhAngle = fullCircle * makruhFraction;
    canvas.drawArc(rect, startAngle + fadilaAngle + permAngle, makruhAngle, false, Paint()
      ..color = AppColors.makruh.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    // Яркая дуга прогресса
    Color progressColor;
    if (progress <= fadilaFraction) {
      progressColor = AppColors.fadila;
    } else if (progress <= fadilaFraction + permissibleFraction) {
      progressColor = AppColors.permissible;
    } else {
      progressColor = AppColors.makruh;
    }

    final progressAngle = fullCircle * progress;
    canvas.drawArc(rect, startAngle, progressAngle, false, Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round);

    // Белая точка-указатель
    final dotAngle = startAngle + progressAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    canvas.drawCircle(Offset(dotX, dotY), 7, Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(dotX, dotY), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(dotX, dotY), 3.5, Paint()..color = progressColor);

    // Декоративные кольца
    canvas.drawCircle(center, radius + strokeWidth / 2 + 10, Paint()
      ..color = AppColors.fadila.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    canvas.drawCircle(center, radius + strokeWidth / 2 + 20, Paint()
      ..color = AppColors.fadila.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);

    // Разделительные метки
    _drawSeparator(canvas, center, radius, startAngle + fadilaAngle);
    _drawSeparator(canvas, center, radius, startAngle + fadilaAngle + permAngle);
  }

  void _drawSeparator(Canvas canvas, Offset center, double radius, double angle) {
    final innerR = radius - strokeWidth / 2 - 2;
    final outerR = radius + strokeWidth / 2 + 2;
    canvas.drawLine(
      Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
      Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle)),
      Paint()..color = Colors.white.withOpacity(0.8)..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant ZonedProgressPainter old) => old.progress != progress;
}