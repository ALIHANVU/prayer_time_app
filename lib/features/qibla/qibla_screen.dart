import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/app_preferences.dart';
import '../../core/l10n/app_localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  /// Сглаженное значение (чтобы стрелка не дёргалась)
  double _smoothHeading = 0;

  /// Направление на Каабу (рассчитывается один раз по координатам)
  late double _qiblaDirection;

  StreamSubscription<CompassEvent>? _subscription;
  bool _hasCompass = true;
  bool _hasData = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _qiblaDirection = _calculateQibla(
      AppPreferences.latitude,
      AppPreferences.longitude,
    );

    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _startCompass();
  }

  void _startCompass() {
    _subscription = FlutterCompass.events?.listen((event) {
      if (!mounted || event.heading == null) return;

      final raw = event.heading!;

      setState(() {
        _hasData = true;
        _smoothHeading = _lerpAngle(_smoothHeading, raw, 0.25);
      });
    }, onError: (e) {
      if (mounted) setState(() => _hasCompass = false);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasData) {
        setState(() => _hasCompass = false);
      }
    });
  }

  /// Плавная интерполяция углов (учитывает переход 359° → 0°)
  double _lerpAngle(double from, double to, double t) {
    double diff = (to - from) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (from + diff * t) % 360;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  /// Формула сферической тригонометрии для направления на Каабу
  double _calculateQibla(double lat, double lon) {
    final latRad = lat * pi / 180;
    final lonRad = lon * pi / 180;
    final kaabaLatRad = _kaabaLat * pi / 180;
    final kaabaLonRad = _kaabaLon * pi / 180;
    final dLon = kaabaLonRad - lonRad;

    final y = sin(dLon) * cos(kaabaLatRad);
    final x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLon);

    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // === Заголовок ===
            Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.qiblaTitle, style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${AppPreferences.cityName}, ${AppPreferences.countryName}',
                      style: AppTextStyles.caption,
                    ),
                  ]),
                ],
              ),
            ]),
            const SizedBox(height: 16),

            // === Направление в градусах ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${strings.qiblaDirection}: ${_qiblaDirection.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // === Компас ===
            if (!_hasCompass)
              _buildNoCompass(strings)
            else if (!_hasData)
              _buildLoading(strings)
            else
              _buildCompass(strings),

            const SizedBox(height: 24),

            // === Подсказка ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.12), width: 1,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.qiblaHowToUse,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(strings.qiblaHowToUseDesc,
                          style: AppTextStyles.caption.copyWith(height: 1.4)),
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(AppStrings strings) {
    final qiblaAngle = _qiblaDirection - _smoothHeading;

    final normalized = ((qiblaAngle % 360) + 360) % 360;
    final isAligned = normalized < 15 || normalized > 345;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Свечение при выравнивании
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isAligned
                      ? AppColors.accent.withOpacity(0.35)
                      : Colors.transparent,
                  blurRadius: 50, spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Белый фон
          Container(
            width: 270, height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20, spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Диск компаса
          Transform.rotate(
            angle: -_smoothHeading * pi / 180,
            child: SizedBox(
              width: 260, height: 260,
              child: CustomPaint(
                painter: _CompassDialPainter(strings: strings),
              ),
            ),
          ),

          // Стрелка на Каабу
          Transform.rotate(
            angle: qiblaAngle * pi / 180,
            child: SizedBox(
              height: 260,
              child: Column(
                children: [
                  Container(
                    width: 3, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isAligned ? AppColors.accent : AppColors.makruh,
                          (isAligned ? AppColors.accent : AppColors.makruh)
                              .withOpacity(0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isAligned ? AppColors.accent : AppColors.makruh)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      color: isAligned ? AppColors.accent : AppColors.makruh,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isAligned ? AppColors.accent : AppColors.makruh)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      strings.qiblaKaaba,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: isAligned ? AppColors.accent : AppColors.makruh,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Центральная точка
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? AppColors.accent : AppColors.textSecondary,
              border: Border.all(color: AppColors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
              ],
            ),
          ),

          // Статус внизу
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isAligned
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAligned
                    ? strings.qiblaAligned
                    : '${_smoothHeading.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isAligned ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(AppStrings strings) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 16),
          Text(strings.qiblaCalibrating,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildNoCompass(AppStrings strings) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sensors_off_rounded,
              size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(strings.qiblaNoCompass,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            '${strings.qiblaNoCompassDesc}\n${strings.qiblaDirection}: ${_qiblaDirection.toStringAsFixed(1)}°',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ]),
      ),
    );
  }
}

/// Рисует круглый диск компаса с метками С, В, Ю, З
class _CompassDialPainter extends CustomPainter {
  final AppStrings strings;
  const _CompassDialPainter({required this.strings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    canvas.drawCircle(center, radius - 20, Paint()
      ..color = AppColors.ringTrack.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    for (int i = 0; i < 360; i += 30) {
      final angle = i * pi / 180 - pi / 2;
      final isCardinal = i % 90 == 0;
      final innerR = radius - (isCardinal ? 25 : 18);
      final outerR = radius - 5;

      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
        Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle)),
        Paint()
          ..color = isCardinal
              ? AppColors.textPrimary.withOpacity(0.6)
              : AppColors.textSecondary.withOpacity(0.3)
          ..strokeWidth = isCardinal ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    for (int i = 0; i < 360; i += 10) {
      if (i % 30 == 0) continue;
      final angle = i * pi / 180 - pi / 2;
      final innerR = radius - 12;
      final outerR = radius - 5;

      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
        Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle)),
        Paint()
          ..color = AppColors.textSecondary.withOpacity(0.15)
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round,
      );
    }

    final labels = {
      0: strings.compassNorth,
      90: strings.compassEast,
      180: strings.compassSouth,
      270: strings.compassWest,
    };
    final colors = {
      0: AppColors.makruh,
      90: AppColors.textSecondary,
      180: AppColors.textSecondary,
      270: AppColors.textSecondary,
    };

    labels.forEach((degrees, label) {
      final angle = degrees * pi / 180 - pi / 2;
      final labelR = radius - 38;

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: colors[degrees] ?? AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        center.dx + labelR * cos(angle) - textPainter.width / 2,
        center.dy + labelR * sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    });
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) => false;
}