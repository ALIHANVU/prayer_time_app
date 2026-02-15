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
      child: Column(
        children: [
          Text(s.nextPrayer.toUpperCase(), style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark))),
          const SizedBox(height: 8),
          Text(s.prayerName(n), style: AppTextStyles.title2.copyWith(color: _txt1(isDark))),
          const SizedBox(height: 4),
          Text(t, style: AppTextStyles.heroTimer.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}