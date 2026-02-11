import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/prayer_calculator.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_preferences.dart';
import 'widgets/zoned_progress_painter.dart';
import 'widgets/prayer_card.dart';
import 'widgets/forbidden_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this)
      ..forward();
  }

  @override
  void dispose() { _timer.cancel(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final prayers = PrayerCalculator.todayPrayers;
    if (prayers.isEmpty) return const Center(child: CircularProgressIndicator());

    final ai = PrayerCalculator.getActivePrayerIndex(_now);
    final prog = PrayerCalculator.getProgress(ai, _now);
    final zone = PrayerCalculator.getCurrentZone(ai, _now);
    final zc = PrayerCalculator.getZoneColor(zone);
    final pn = {'fajr': s.fajr, 'dhuhr': s.dhuhr, 'asr': s.asr,
      'maghrib': s.maghrib, 'isha': s.isha};

    final name = ai >= 0 ? pn[prayers[ai].id] ?? '' : s.nextPrayer;
    final rem = PrayerCalculator.getTimeRemaining(ai, _now);
    final range = ai >= 0
        ? '${prayers[ai].startTimeFormatted} — ${prayers[ai].endTimeFormatted}' : '';

    double ff = 0.33, pf = 0.34;
    if (ai >= 0) { ff = prayers[ai].fadilaFraction; pf = prayers[ai].permissibleFraction; }

    final actForbid = PrayerCalculator.getActiveForbiddenTime(_now);
    final upForbid = PrayerCalculator.getUpcomingForbiddenTime(_now);

    String zoneName;
    switch (zone) {
      case PrayerZone.fadila: zoneName = s.zoneFadila; break;
      case PrayerZone.permissible: zoneName = s.zonePermissible; break;
      case PrayerZone.makruh: zoneName = s.zoneMakruh; break;
      case PrayerZone.expired: zoneName = s.zoneMissed; break;
    }

    return FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              const SizedBox(height: 56),
              _header(s),
              const SizedBox(height: 8),
              _dateCard(s),
              const SizedBox(height: 16),

              // Баннер запретного времени
              if (actForbid != null)
                ForbiddenBanner(forbidden: actForbid, isActive: true, strings: s),
              if (actForbid == null && upForbid != null)
                ForbiddenBanner(forbidden: upForbid, isActive: false, now: _now, strings: s),

              // Кольцо прогресса
              _circle(name, rem, range, prog, zone, zc, ai, s, zoneName, ff, pf),
              const SizedBox(height: 8),
              _zoneLegend(s),
              const SizedBox(height: 24),

              // Заголовок расписания
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text(s.scheduleTitle, style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 2,
                          color: AppColors.textMuted)))),
              const SizedBox(height: 12),

              // Фаджр
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PrayerCard(prayer: prayers[0],
                      localizedName: pn[prayers[0].id] ?? prayers[0].id,
                      status: PrayerCalculator.getStatus(0, ai, _now),
                      zone: ai == 0 ? zone : PrayerZone.expired,
                      isActive: ai == 0, now: _now)),

              // Восход
              _sunriseDivider(s),

              // Остальные намазы
              ...List.generate(prayers.length - 1, (i) {
                final idx = i + 1;
                return Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PrayerCard(prayer: prayers[idx],
                        localizedName: pn[prayers[idx].id] ?? prayers[idx].id,
                        status: PrayerCalculator.getStatus(idx, ai, _now),
                        zone: ai == idx ? zone : PrayerZone.expired,
                        isActive: ai == idx, now: _now));
              }),
              const SizedBox(height: 100),
            ])));
  }

  Widget _header(AppStrings s) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.appTitle, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${AppPreferences.cityName}, ${AppPreferences.countryName}',
                style: AppTextStyles.caption)])]),
        Container(width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10,
                    offset: const Offset(0, 2))]),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22))]));

  Widget _dateCard(AppStrings s) {
    // Используем методы из AppStrings вместо несуществующих геттеров
    final mn = s.monthNameOf(_now.month);
    final wd = s.weekdayName(_now.weekday);
    final h = PrayerCalculator.hijriDate;
    return Center(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.08), blurRadius: 20,
                offset: const Offset(0, 4))]),
        child: Column(children: [
          Text(s.today, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.accent, letterSpacing: 2)),
          const SizedBox(height: 3),
          Text('$wd, ${_now.day} $mn ${_now.year}', style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          if (h.isNotEmpty) ...[const SizedBox(height: 2), Text(h, style: AppTextStyles.caption)]])));
  }

  Widget _circle(String name, String time, String range, double prog,
      PrayerZone z, Color zc, int ai, AppStrings s, String zoneName,
      double ff, double pf) {
    return Center(child: SizedBox(width: 240, height: 240,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(240, 240),
              painter: ZonedProgressPainter(
                  fadilaFraction: ff, permissibleFraction: pf,
                  progress: prog, zone: z)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(time, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                color: zc, fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: zc.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(
                      color: zc, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(zoneName, style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: zc))])),
            const SizedBox(height: 4),
            Text(range, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])])));
  }

  Widget _zoneLegend(AppStrings s) => Row(
      mainAxisAlignment: MainAxisAlignment.center, children: [
    _legendItem(AppColors.fadila, s.zoneFadila),
    const SizedBox(width: 16),
    _legendItem(AppColors.permissible, s.zonePermissible),
    const SizedBox(width: 16),
    _legendItem(AppColors.makruh, s.zoneMakruh)]);

  Widget _legendItem(Color c, String text) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary,
        fontWeight: FontWeight.w500))]);

  Widget _sunriseDivider(AppStrings s) {
    final sr = PrayerCalculator.sunriseMinutes;
    final h = sr ~/ 60; final m = sr % 60;
    final t = '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Row(children: [
          Expanded(child: Container(height: 1,
              decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.permissible.withOpacity(0.5), Colors.transparent])))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('☀️ ${s.sunriseTitle} $t', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.permissible))),
          Expanded(child: Container(height: 1,
              decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.permissible.withOpacity(0.5), Colors.transparent]))))]));
  }
}