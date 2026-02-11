import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/prayer_calculator.dart';

/// ═══════════════════════════════════════════════════════
/// КОЛЬЦО ПРОГРЕССА С ТРЕМЯ ЗОНАМИ
///
/// Кольцо показывает 3 цветных сектора:
///   🟢 Фадиля (изумруд)  — лучшее время
///   🟡 Допустимо (золото) — можно, но не тяни
///   🔴 Макрух (красный)   — нежелательно
///
/// Цвета плавно перетекают один в другой:
///   Зелёный → Жёлтый → Красный
///
/// Белая точка на кольце показывает текущее положение.
/// ═══════════════════════════════════════════════════════

class ZonedProgressPainter extends CustomPainter {
  final double fadilaFraction;
  final double permissibleFraction;
  final double progress;
  final PrayerZone zone;

  ZonedProgressPainter({
    required this.fadilaFraction,
    required this.permissibleFraction,
    required this.progress,
    required this.zone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 13.0;
    const startAngle = -pi / 2; // 12 часов

    // ═══ Фоновое кольцо ═══
    final bgPaint = Paint()
      ..color = const Color(0xFFE8EDE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final totalAngle = 2 * pi;
    final fadilaAngle = fadilaFraction * totalAngle;
    final permAngle = permissibleFraction * totalAngle;
    final makruhAngle = (1.0 - fadilaFraction - permissibleFraction) * totalAngle;

    // ═══ Зона ФАДИЛЯ (зелёная) ═══
    final fadilaPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Градиент: чисто зелёный → зелёно-жёлтый
    fadilaPaint.shader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + fadilaAngle,
      colors: const [
        Color(0xFF2D9F6F), // чистый изумруд
        Color(0xFF3DBB85), // светлый изумруд
        Color(0xFF6BBF59), // переход к жёлтому
      ],
      stops: const [0.0, 0.6, 1.0],
      transform: const GradientRotation(-pi / 2),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fadilaAngle,
      false,
      fadilaPaint,
    );

    // ═══ Зона ДОПУСТИМО (жёлтая) ═══
    final permPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    permPaint.shader = SweepGradient(
      startAngle: startAngle + fadilaAngle,
      endAngle: startAngle + fadilaAngle + permAngle,
      colors: const [
        Color(0xFFA8B520), // жёлто-зелёный
        Color(0xFFD4A017), // золото
        Color(0xFFE8A010), // тёмное золото
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-pi / 2),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + fadilaAngle,
      permAngle,
      false,
      permPaint,
    );

    // ═══ Зона МАКРУХ (красная) ═══
    final makruhPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    makruhPaint.shader = SweepGradient(
      startAngle: startAngle + fadilaAngle + permAngle,
      endAngle: startAngle + totalAngle,
      colors: const [
        Color(0xFFE07020), // оранжево-красный
        Color(0xFFC0392B), // красный
        Color(0xFFA93226), // тёмно-красный
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-pi / 2),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + fadilaAngle + permAngle,
      makruhAngle,
      false,
      makruhPaint,
    );

    // ═══ Разделители между зонами ═══
    final divPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Между Фадиля и Допустимо
    final div1Angle = startAngle + fadilaAngle;
    final div1Start = Offset(
      center.dx + (radius - strokeWidth / 2 - 1) * cos(div1Angle),
      center.dy + (radius - strokeWidth / 2 - 1) * sin(div1Angle),
    );
    final div1End = Offset(
      center.dx + (radius + strokeWidth / 2 + 1) * cos(div1Angle),
      center.dy + (radius + strokeWidth / 2 + 1) * sin(div1Angle),
    );
    canvas.drawLine(div1Start, div1End, divPaint);

    // Между Допустимо и Макрух
    final div2Angle = startAngle + fadilaAngle + permAngle;
    final div2Start = Offset(
      center.dx + (radius - strokeWidth / 2 - 1) * cos(div2Angle),
      center.dy + (radius - strokeWidth / 2 - 1) * sin(div2Angle),
    );
    final div2End = Offset(
      center.dx + (radius + strokeWidth / 2 + 1) * cos(div2Angle),
      center.dy + (radius + strokeWidth / 2 + 1) * sin(div2Angle),
    );
    canvas.drawLine(div2Start, div2End, divPaint);

    // ═══ Точка прогресса (белая) ═══
    if (progress > 0 && progress < 1) {
      final dotAngle = startAngle + progress * totalAngle;
      final dotCenter = Offset(
        center.dx + radius * cos(dotAngle),
        center.dy + radius * sin(dotAngle),
      );

      // Тень
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(dotCenter, 7, shadowPaint);

      // Белая точка
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, 6, dotPaint);

      // Цветная обводка
      Color dotBorder;
      if (progress <= fadilaFraction) {
        dotBorder = AppColors.fadila;
      } else if (progress <= fadilaFraction + permissibleFraction) {
        dotBorder = AppColors.permissible;
      } else {
        dotBorder = AppColors.makruh;
      }
      final borderPaint = Paint()
        ..color = dotBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(dotCenter, 6, borderPaint);
    }
  }

  @override
  bool shouldRepaint(ZonedProgressPainter old) =>
      old.progress != progress ||
          old.fadilaFraction != fadilaFraction ||
          old.zone != zone;
}