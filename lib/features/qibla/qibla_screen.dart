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

class _QiblaScreenState extends State<QiblaScreen> {
  double _smoothHeading = 0;
  late double _qiblaDirection;
  StreamSubscription<CompassEvent>? _sub;
  bool _hasCompass = true;
  bool _hasData = false;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _qiblaDirection = _calcQibla(AppPreferences.latitude, AppPreferences.longitude);
    _startCompass();
  }

  void _startCompass() {
    _sub = FlutterCompass.events?.listen((e) {
      if (!mounted || e.heading == null) return;
      setState(() {
        _hasData = true;
        _smoothHeading = _lerp(_smoothHeading, e.heading!, 0.25);
      });
    }, onError: (_) {
      if (mounted) setState(() => _hasCompass = false);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasData) setState(() => _hasCompass = false);
    });
  }

  double _lerp(double from, double to, double t) {
    double d = (to - from) % 360;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return (from + d * t) % 360;
  }

  double _calcQibla(double lat, double lon) {
    final lr = lat * pi / 180;
    final lonr = lon * pi / 180;
    final klr = _kaabaLat * pi / 180;
    final klonr = _kaabaLon * pi / 180;
    final dlon = klonr - lonr;
    final y = sin(dlon) * cos(klr);
    final x = cos(lr) * sin(klr) - sin(lr) * cos(klr) * cos(dlon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(s.qiblaTitle, style: AppTextStyles.largeTitle.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          )),
          const SizedBox(height: 2),
          Text(
            '${AppPreferences.cityName} · ${_qiblaDirection.toStringAsFixed(1)}°',
            style: AppTextStyles.subheadline,
          ),
          const SizedBox(height: 30),

          if (!_hasCompass)
            _noCompass(s, isDark)
          else if (!_hasData)
            _loading(s)
          else
            _compass(s, isDark),

          const SizedBox(height: 24),

          // Подсказка
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  s.qiblaHowToUseDesc,
                  style: AppTextStyles.footnote.copyWith(height: 1.4),
                )),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _compass(AppStrings s, bool isDark) {
    final qiblaAngle = _qiblaDirection - _smoothHeading;
    final norm = ((qiblaAngle % 360) + 360) % 360;
    final aligned = norm < 12 || norm > 348;

    return Center(
      child: SizedBox(
        width: 280, height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Фон
            Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
            ),

            // Диск компаса
            Transform.rotate(
              angle: -_smoothHeading * pi / 180,
              child: SizedBox(
                width: 250, height: 250,
                child: CustomPaint(painter: _CompassPainter(strings: s, isDark: isDark)),
              ),
            ),

            // Стрелка Каабы
            Transform.rotate(
              angle: qiblaAngle * pi / 180,
              child: SizedBox(
                height: 250,
                child: Column(
                  children: [
                    Container(
                      width: 2, height: 70,
                      decoration: BoxDecoration(
                        color: aligned ? AppColors.fadila : AppColors.makruh,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (aligned ? AppColors.fadila : AppColors.makruh).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mosque_rounded,
                          color: aligned ? AppColors.fadila : AppColors.makruh, size: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(s.qiblaKaaba, style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w600,
                      color: aligned ? AppColors.fadila : AppColors.makruh,
                    )),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Центр
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: aligned ? AppColors.fadila : AppColors.textSecondary,
                border: Border.all(color: isDark ? AppColors.surfaceDark : AppColors.surface, width: 2),
              ),
            ),

            // Статус
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: aligned
                      ? AppColors.fadila.withOpacity(0.12)
                      : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  aligned ? s.qiblaAligned : '${_smoothHeading.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: aligned ? AppColors.fadila : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading(AppStrings s) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(s.qiblaCalibrating, style: AppTextStyles.subheadline),
        ]),
      ),
    );
  }

  Widget _noCompass(AppStrings s, bool isDark) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sensors_off_rounded, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(s.qiblaNoCompass, style: AppTextStyles.headline.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('${s.qiblaDirection}: ${_qiblaDirection.toStringAsFixed(1)}°',
              style: AppTextStyles.subheadline),
        ]),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final AppStrings strings;
  final bool isDark;
  const _CompassPainter({required this.strings, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Кольцо
    canvas.drawCircle(center, r, Paint()
      ..color = isDark ? AppColors.ringTrackDark : AppColors.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Деления
    for (int i = 0; i < 360; i += 30) {
      final a = i * pi / 180 - pi / 2;
      final card = i % 90 == 0;
      final inner = r - (card ? 22 : 15);
      final outer = r - 4;
      canvas.drawLine(
        Offset(center.dx + inner * cos(a), center.dy + inner * sin(a)),
        Offset(center.dx + outer * cos(a), center.dy + outer * sin(a)),
        Paint()
          ..color = card
              ? (isDark ? AppColors.textSecondaryDark : AppColors.textPrimary).withOpacity(0.5)
              : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary)
          ..strokeWidth = card ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    // Метки C В Ю З
    final labels = {0: strings.compassNorth, 90: strings.compassEast,
      180: strings.compassSouth, 270: strings.compassWest};
    final colors = {0: AppColors.makruh, 90: AppColors.textSecondary,
      180: AppColors.textSecondary, 270: AppColors.textSecondary};

    labels.forEach((deg, label) {
      final a = deg * pi / 180 - pi / 2;
      final lr = r - 34;
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: colors[deg] ?? AppColors.textSecondary,
        )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(
        center.dx + lr * cos(a) - tp.width / 2,
        center.dy + lr * sin(a) - tp.height / 2,
      ));
    });
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) => old.isDark != isDark;
}