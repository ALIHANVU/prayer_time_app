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

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Заголовок — как на главном экране
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.qiblaTitle, style: AppTextStyles.largeTitle.copyWith(color: _txt1(isDark))),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${AppPreferences.cityName}, ${AppPreferences.countryName}',
              style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark)),
            ),
          ),

          const SizedBox(height: 20),

          // Hero-карточка компаса
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.heroStartDark, AppColors.heroEndDark]
                    : [AppColors.heroStartLight, AppColors.heroEndLight],
              ),
              border: Border.all(color: _sep(isDark), width: 1),
              boxShadow: isDark ? null : [
                BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60, right: -40,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.accent.withOpacity(isDark ? 0.12 : 0.07),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                  child: Column(
                    children: [
                      // Направление
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.qiblaDirection.toUpperCase(),
                                  style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark), letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('🕋', style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Text(s.qiblaKaaba, style: AppTextStyles.heroPrayerName.copyWith(color: _txt1(isDark))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_qiblaDirection.toStringAsFixed(1)}°',
                                style: AppTextStyles.heroTimer.copyWith(color: AppColors.accent),
                              ),
                              const SizedBox(height: 4),
                              Text(s.qiblaDirection, style: AppTextStyles.caption2.copyWith(color: _txt3(isDark))),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Компас
                      if (!_hasCompass)
                        _noCompassContent(s, isDark)
                      else if (!_hasData)
                        _loadingContent(s)
                      else
                        _compassContent(s, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Подсказка — как карточка
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surf(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _sep(isDark)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(isDark ? 0.10 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('📱', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.qiblaHowToUse,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _txt1(isDark)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.qiblaHowToUseDesc,
                        style: AppTextStyles.footnote.copyWith(height: 1.4, color: _txt3(isDark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _compassContent(AppStrings s, bool isDark) {
    final qiblaAngle = _qiblaDirection - _smoothHeading;
    final norm = ((qiblaAngle % 360) + 360) % 360;
    final aligned = norm < 12 || norm > 348;

    return Column(
      children: [
        SizedBox(
          width: 260, height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Фон
              Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
                ),
              ),

              // Диск компаса
              Transform.rotate(
                angle: -_smoothHeading * pi / 180,
                child: SizedBox(
                  width: 240, height: 240,
                  child: CustomPaint(painter: _CompassPainter(strings: s, isDark: isDark)),
                ),
              ),

              // Стрелка Каабы
              Transform.rotate(
                angle: qiblaAngle * pi / 180,
                child: SizedBox(
                  height: 240,
                  child: Column(
                    children: [
                      Container(
                        width: 2, height: 65,
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
                            color: aligned ? AppColors.fadila : AppColors.makruh, size: 18),
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Статус
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: aligned
                ? AppColors.fadila.withOpacity(0.12)
                : (isDark ? AppColors.surface3Dark : AppColors.surface3Light),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (aligned) ...[
                Container(width: 6, height: 6,
                    decoration: const BoxDecoration(color: AppColors.fadila, shape: BoxShape.circle)),
                const SizedBox(width: 6),
              ],
              Text(
                aligned ? s.qiblaAligned : '${_smoothHeading.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: aligned ? AppColors.fadila : _txt2(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadingContent(AppStrings s) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(s.qiblaCalibrating, style: AppTextStyles.subheadline),
        ]),
      ),
    );
  }

  Widget _noCompassContent(AppStrings s, bool isDark) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.sensors_off_rounded, size: 28, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text(s.qiblaNoCompass, style: AppTextStyles.headline.copyWith(color: _txt1(isDark))),
          const SizedBox(height: 8),
          Text(s.qiblaNoCompassDesc, style: AppTextStyles.footnote.copyWith(color: _txt3(isDark)), textAlign: TextAlign.center),
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

    // Метки
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