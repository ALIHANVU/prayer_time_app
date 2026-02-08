import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/app_preferences.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _heading; // Куда смотрит телефон (от датчика компаса)
  late double _qiblaDirection; // Направление на Каабу (рассчитывается)
  StreamSubscription<CompassEvent>? _subscription;
  bool _hasCompass = true;

  // Координаты Каабы (Мекка)
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _qiblaDirection = _calculateQibla(
      AppPreferences.latitude,
      AppPreferences.longitude,
    );
    _startCompass();
  }

  void _startCompass() {
    _subscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() => _heading = event.heading);
      }
    }, onError: (e) {
      setState(() => _hasCompass = false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Рассчитать направление на Каабу в градусах от севера.
  /// Формула сферической тригонометрии.
  double _calculateQibla(double lat, double lon) {
    final latRad = lat * pi / 180;
    final lonRad = lon * pi / 180;
    final kaabaLatRad = _kaabaLat * pi / 180;
    final kaabaLonRad = _kaabaLon * pi / 180;

    final dLon = kaabaLonRad - lonRad;

    final y = sin(dLon) * cos(kaabaLatRad);
    final x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLon);

    var bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360; // Нормализуем 0–360
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Заголовок
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Кыбла', style: AppTextStyles.heading),
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
            ],
          ),
          const SizedBox(height: 16),

          // Информация о направлении
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
                  'Направление: ${_qiblaDirection.toStringAsFixed(1)}°',
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

          // Компас
          if (!_hasCompass)
            _buildNoCompass()
          else if (_heading == null)
            _buildLoading()
          else
            _buildCompass(),

          const SizedBox(height: 24),

          // Подсказка
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.12),
                width: 1,
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
                    const Text(
                      'Как пользоваться',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Держите телефон горизонтально. '
                          'Стрелка показывает направление на Каабу. '
                          'Зелёный цвет = вы смотрите в сторону Кыблы.',
                      style: AppTextStyles.caption.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    // Угол, на который нужно повернуть стрелку Кыблы
    // = направление_на_каабу - куда_смотрит_телефон
    final qiblaAngle = _qiblaDirection - (_heading ?? 0);

    // Проверяем, смотрит ли пользователь ±15° от Кыблы
    final diff = ((qiblaAngle % 360) + 360) % 360;
    final isAligned = diff < 15 || diff > 345;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Внешнее свечение при выравнивании
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isAligned
                      ? AppColors.accent.withOpacity(0.3)
                      : Colors.transparent,
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Круг компаса с метками сторон света
          Transform.rotate(
            angle: -(_heading ?? 0) * pi / 180,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _CompassPainter(),
            ),
          ),

          // Стрелка на Кыблу
          Transform.rotate(
            angle: qiblaAngle * pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation_rounded,
                  color: isAligned ? AppColors.accent : AppColors.makruh,
                  size: 48,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isAligned ? AppColors.accent : AppColors.makruh)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Кааба',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isAligned ? AppColors.accent : AppColors.makruh,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Центральная точка
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? AppColors.accent : AppColors.textSecondary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
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
                isAligned ? '✅ Вы смотрите на Кыблу!' : '${_heading?.toStringAsFixed(0) ?? "--"}°',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isAligned ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Калибровка компаса...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCompass() {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_off_rounded,
                size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Компас недоступен',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'На этом устройстве нет датчика компаса.\n'
                  'Направление на Кыблу: ${_qiblaDirection.toStringAsFixed(1)}°',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Рисует круг компаса с метками N, E, S, W и градусными делениями
class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Внешний круг
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = AppColors.ringTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Внутренний круг
    canvas.drawCircle(
      center, radius - 20,
      Paint()
        ..color = AppColors.ringTrack.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Деления по кругу (каждые 30°)
    for (int i = 0; i < 360; i += 30) {
      final angle = i * pi / 180 - pi / 2;
      final isCardinal = i % 90 == 0;
      final innerR = radius - (isCardinal ? 25 : 18);
      final outerR = radius - 5;

      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle),
            center.dy + innerR * sin(angle)),
        Offset(center.dx + outerR * cos(angle),
            center.dy + outerR * sin(angle)),
        Paint()
          ..color = isCardinal
              ? AppColors.textPrimary.withOpacity(0.6)
              : AppColors.textSecondary.withOpacity(0.3)
          ..strokeWidth = isCardinal ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Метки N, E, S, W
    const labels = {0: 'С', 90: 'В', 180: 'Ю', 270: 'З'};
    const colors = {
      0: AppColors.makruh, // Север — красный
      90: AppColors.textSecondary,
      180: AppColors.textSecondary,
      270: AppColors.textSecondary,
    };

    labels.forEach((degrees, label) {
      final angle = degrees * pi / 180 - pi / 2;
      final labelR = radius - 38;
      final offset = Offset(
        center.dx + labelR * cos(angle) - 6,
        center.dy + labelR * sin(angle) - 8,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors[degrees] ?? AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, offset);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}