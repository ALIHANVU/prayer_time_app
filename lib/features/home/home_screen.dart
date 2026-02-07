import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/prayer_calculator.dart';
import '../../core/l10n/app_localizations.dart';
import 'widgets/zoned_progress_painter.dart';
import 'widgets/prayer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() { _timer.cancel(); _fadeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final prayers = PrayerCalculator.todayPrayers;
    final activeIdx = PrayerCalculator.getActivePrayerIndex(_now);
    final progress = PrayerCalculator.getProgress(activeIdx, _now);
    final zone = PrayerCalculator.getCurrentZone(activeIdx, _now);
    final zoneColor = PrayerCalculator.getZoneColor(zone);

    final prayerNames = {
      'fajr': strings.fajr, 'dhuhr': strings.dhuhr,
      'asr': strings.asr, 'maghrib': strings.maghrib, 'isha': strings.isha,
    };

    final activeName = activeIdx >= 0 ? prayerNames[prayers[activeIdx].id] ?? '' : '—';
    final timeRemaining = PrayerCalculator.getTimeRemaining(activeIdx, _now);
    final timeRange = activeIdx >= 0
        ? '${prayers[activeIdx].startTimeFormatted} — ${prayers[activeIdx].endTimeFormatted}' : '';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          _buildHeader(strings),
          const SizedBox(height: 20),
          _buildDateCard(strings),
          const SizedBox(height: 24),
          _buildProgressCircle(activeName, timeRemaining, timeRange, progress, zone, zoneColor, activeIdx),
          const SizedBox(height: 12),
          _buildZoneLegend(zone),
          const SizedBox(height: 20),
          _buildSunriseWarning(strings),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(strings.scheduleTitle, style: AppTextStyles.sectionLabel),
            Text('${strings.nextPrayer}: ${PrayerCalculator.getNextPrayerTime(_now)}', style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 12),
          ...List.generate(prayers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PrayerCard(
              prayer: prayers[i],
              status: PrayerCalculator.getStatus(i, activeIdx, _now),
              currentZone: i == activeIdx ? zone : PrayerZone.expired,
              localizedName: prayerNames[prayers[i].id] ?? prayers[i].id,
            ),
          )),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppStrings strings) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(strings.appTitle, style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('Ца-Ведено, Россия', style: AppTextStyles.caption),
        ]),
      ]),
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
      ),
    ]);
  }

  Widget _buildDateCard(AppStrings strings) {
    const months = ['', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];

    return Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Text(strings.today, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('${days[_now.weekday - 1]}, ${_now.day} ${months[_now.month]} ${_now.year}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text('27 Шаабен 1447 г.х.', style: AppTextStyles.caption),
      ]),
    ));
  }

  Widget _buildProgressCircle(String prayerName, String timeRemaining, String timeRange,
      double progress, PrayerZone zone, Color zoneColor, int activeIdx) {
    double fadilaF = 0.4, permF = 0.35;
    if (activeIdx >= 0) {
      final p = PrayerCalculator.todayPrayers[activeIdx];
      fadilaF = p.fadilaFraction;
      permF = p.permissibleFraction;
    }

    return Center(child: SizedBox(width: 230, height: 230, child: Stack(alignment: Alignment.center, children: [
      Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: zoneColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 5)])),
      Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, spreadRadius: 2)])),
      SizedBox(width: 210, height: 210, child: CustomPaint(
          painter: ZonedProgressPainter(progress: progress, fadilaFraction: fadilaF, permissibleFraction: permF))),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(prayerName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(timeRemaining, style: AppTextStyles.timerLarge),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: zoneColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(PrayerCalculator.getZoneName(zone),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: zoneColor)),
        ),
        const SizedBox(height: 6),
        Text(timeRange, style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7))),
      ]),
    ])));
  }

  Widget _buildZoneLegend(PrayerZone currentZone) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _zoneDot(AppColors.fadila, 'Фадиля', currentZone == PrayerZone.fadila),
      const SizedBox(width: 16),
      _zoneDot(AppColors.permissible, 'Допустимо', currentZone == PrayerZone.permissible),
      const SizedBox(width: 16),
      _zoneDot(AppColors.makruh, 'Макрух', currentZone == PrayerZone.makruh),
    ]);
  }

  Widget _zoneDot(Color color, String label, bool isActive) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(
          color: color.withOpacity(isActive ? 1.0 : 0.35), shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }

  Widget _buildSunriseWarning(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.12), width: 1)),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.wb_sunny_outlined, color: AppColors.accent, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${strings.sunriseTitle} — ${PrayerCalculator.sunriseFormatted}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(strings.sunriseSubtitle, style: AppTextStyles.caption),
        ])),
      ]),
    );
  }
}