import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/prayer_calculator.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_preferences.dart';
import 'widgets/hero_card.dart';
import 'widgets/prayer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayers = PrayerCalculator.todayPrayers;

    if (prayers.isEmpty) return const Center(child: CircularProgressIndicator());

    final ai = PrayerCalculator.getActivePrayerIndex(_now);
    final zone = PrayerCalculator.getCurrentZone(ai, _now);
    final progress = PrayerCalculator.getProgress(ai, _now);
    final remaining = PrayerCalculator.getTimeRemaining(ai, _now);
    final actForbid = PrayerCalculator.getActiveForbiddenTime(_now);
    final upForbid = PrayerCalculator.getUpcomingForbiddenTime(_now);

    final names = {'fajr': s.fajr, 'dhuhr': s.dhuhr, 'asr': s.asr, 'maghrib': s.maghrib, 'isha': s.isha};

    // Время Духа: после восхода +15 мин до Зухра -15 мин
    final sunriseMin = PrayerCalculator.sunriseMinutes;
    final duhaStart = sunriseMin + 15;
    final dhuhrPrayer = prayers.firstWhere((p) => p.id == 'dhuhr', orElse: () => prayers[1]);
    final duhaEnd = dhuhrPrayer.startMin - 15;
    final nowMin = _now.hour * 60 + _now.minute;
    final isDuhaTime = nowMin >= duhaStart && nowMin < duhaEnd;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.appTitle, style: AppTextStyles.largeTitle.copyWith(color: _txt1(isDark))),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('${AppPreferences.cityName}, ${AppPreferences.countryName}',
                style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark))),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _dateRow(s, isDark),
          ),

          if (ai >= 0)
            HeroCard(
              prayer: prayers[ai], localizedName: names[prayers[ai].id] ?? '',
              zone: zone, progress: progress, timeRemaining: remaining,
              nextPrayerName: PrayerCalculator.getNextPrayerName(_now),
              nextPrayerTime: PrayerCalculator.getNextPrayerTime(_now),
              sunriseMinutes: PrayerCalculator.sunriseMinutes,
              activeForbidden: actForbid, upcomingForbidden: upForbid,
              now: _now, strings: s,
            )
          else
            _nextCard(s, isDark),

          // Карточка намаза Духа
          if (isDuhaTime) _duhaCard(s, isDark, duhaStart, duhaEnd),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Text(s.scheduleTitle.toUpperCase(),
                style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(prayers.length, (i) => PrayerCard(
                prayer: prayers[i], localizedName: names[prayers[i].id] ?? prayers[i].id,
                status: PrayerCalculator.getStatus(i, ai, _now),
                zone: ai == i ? zone : PrayerZone.expired,
                isActive: ai == i, now: _now,
              )),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _dateRow(AppStrings s, bool isDark) {
    final hijri = PrayerCalculator.hijriDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${s.weekdayName(_now.weekday)}, ${_now.day} ${s.monthNameOf(_now.month)}',
            style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark))),
        if (hijri.isNotEmpty)
          Text(hijri, style: AppTextStyles.caption1.copyWith(color: _txt3(isDark))),
      ],
    );
  }

  Widget _nextCard(AppStrings s, bool isDark) {
    final n = PrayerCalculator.getNextPrayerName(_now);
    final t = PrayerCalculator.getNextPrayerTime(_now);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(color: isDark ? AppColors.separatorDark : AppColors.separator),
        boxShadow: isDark ? null : [BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Text(s.nextPrayer.toUpperCase(), style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark))),
        const SizedBox(height: 8),
        Text(s.prayerName(n), style: AppTextStyles.title2.copyWith(color: _txt1(isDark))),
        const SizedBox(height: 4),
        Text(t, style: AppTextStyles.heroTimer.copyWith(color: AppColors.accent)),
      ]),
    );
  }

  /// Карточка намаза Духа
  Widget _duhaCard(AppStrings s, bool isDark, int startMin, int endMin) {
    final startH = startMin ~/ 60; final startM = startMin % 60;
    final endH = endMin ~/ 60; final endM = endMin % 60;
    final startStr = '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
    final endStr = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.permissible.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.permissible.withOpacity(isDark ? 0.10 : 0.08), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('🌞', style: TextStyle(fontSize: 20))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.duha, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _txt1(isDark))),
          const SizedBox(height: 2),
          Text('$startStr – $endStr', style: TextStyle(fontSize: 12, color: _txt3(isDark))),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.permissible.withOpacity(isDark ? 0.10 : 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text('2–12', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.permissible))),
      ]),
    );
  }
}