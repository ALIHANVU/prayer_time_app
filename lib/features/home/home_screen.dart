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

  // Кешируем Map имён — он не меняется без смены языка
  Map<String, String> _names = {};
  String _cachedLang = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() => _now = DateTime.now());
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Кешируем имена намазов чтобы не создавать Map каждую секунду
  Map<String, String> _getPrayerNames(AppStrings s) {
    final lang = AppPreferences.language;
    if (_cachedLang != lang) {
      _cachedLang = lang;
      _names = {
        'fajr': s.fajr,
        'dhuhr': s.dhuhr,
        'asr': s.asr,
        'maghrib': s.maghrib,
        'isha': s.isha,
      };
    }
    return _names;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayers = PrayerCalculator.todayPrayers;

    if (prayers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ai = PrayerCalculator.getActivePrayerIndex(_now);
    final zone = PrayerCalculator.getCurrentZone(ai, _now);
    final progress = PrayerCalculator.getProgress(ai, _now);
    final remaining = PrayerCalculator.getTimeRemaining(ai, _now);
    final actForbid = PrayerCalculator.getActiveForbiddenTime(_now);
    final upForbid = PrayerCalculator.getUpcomingForbiddenTime(_now);
    final names = _getPrayerNames(s);

    // Духа
    final sunriseMin = PrayerCalculator.sunriseMinutes;
    final duhaStart = sunriseMin + 15;
    final dhuhrPrayer = prayers.firstWhere(
          (p) => p.id == 'dhuhr',
      orElse: () => prayers[1],
    );
    final duhaEnd = dhuhrPrayer.startMin - 15;
    final nowMin = _now.hour * 60 + _now.minute;
    final isDuhaTime = nowMin >= duhaStart && nowMin < duhaEnd;

    final txt1 = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final txt2 = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final txt3 = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.appTitle, style: AppTextStyles.largeTitle.copyWith(color: txt1)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${AppPreferences.cityName}, ${AppPreferences.countryName}',
              style: AppTextStyles.subheadline.copyWith(color: txt2),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _DateRow(now: _now, strings: s, txt2: txt2, txt3: txt3),
          ),

          if (ai >= 0)
            HeroCard(
              prayer: prayers[ai],
              localizedName: names[prayers[ai].id] ?? '',
              zone: zone,
              progress: progress,
              timeRemaining: remaining,
              nextPrayerName: PrayerCalculator.getNextPrayerName(_now),
              nextPrayerTime: PrayerCalculator.getNextPrayerTime(_now),
              sunriseMinutes: sunriseMin,
              activeForbidden: actForbid,
              upcomingForbidden: upForbid,
              now: _now,
              strings: s,
            )
          else
            _NextCard(now: _now, strings: s, isDark: isDark),

          if (isDuhaTime)
            _DuhaCard(
              strings: s,
              isDark: isDark,
              startMin: duhaStart,
              endMin: duhaEnd,
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Text(
              s.scheduleTitle.toUpperCase(),
              style: AppTextStyles.sectionHeader.copyWith(color: txt3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(prayers.length, (i) {
                return PrayerCard(
                  prayer: prayers[i],
                  localizedName: names[prayers[i].id] ?? prayers[i].id,
                  status: PrayerCalculator.getStatus(i, ai, _now),
                  zone: ai == i ? zone : PrayerZone.expired,
                  isActive: ai == i,
                  now: _now,
                );
              }),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

/// Виджет даты — вынесен чтобы не пересоздавать при каждом build
class _DateRow extends StatelessWidget {
  final DateTime now;
  final AppStrings strings;
  final Color txt2;
  final Color txt3;

  const _DateRow({
    required this.now,
    required this.strings,
    required this.txt2,
    required this.txt3,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = PrayerCalculator.hijriDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${strings.weekdayName(now.weekday)}, ${now.day} ${strings.monthNameOf(now.month)}',
          style: AppTextStyles.subheadline.copyWith(color: txt2),
        ),
        if (hijri.isNotEmpty)
          Text(
            hijri,
            style: AppTextStyles.caption1.copyWith(color: txt3),
          ),
      ],
    );
  }
}

/// Карточка «Следующий намаз» — вынесена в отдельный виджет
class _NextCard extends StatelessWidget {
  final DateTime now;
  final AppStrings strings;
  final bool isDark;

  const _NextCard({
    required this.now,
    required this.strings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final n = PrayerCalculator.getNextPrayerName(now);
    final t = PrayerCalculator.getNextPrayerTime(now);
    final txt1 = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final txt3 = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: isDark ? AppColors.separatorDark : AppColors.separator,
        ),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Text(
          strings.nextPrayer.toUpperCase(),
          style: AppTextStyles.sectionHeader.copyWith(color: txt3),
        ),
        const SizedBox(height: 8),
        Text(
          strings.prayerName(n),
          style: AppTextStyles.title2.copyWith(color: txt1),
        ),
        const SizedBox(height: 4),
        Text(
          t,
          style: AppTextStyles.heroTimer.copyWith(color: AppColors.accent),
        ),
      ]),
    );
  }
}

/// Карточка Духа — вынесена в отдельный виджет
class _DuhaCard extends StatelessWidget {
  final AppStrings strings;
  final bool isDark;
  final int startMin;
  final int endMin;

  const _DuhaCard({
    required this.strings,
    required this.isDark,
    required this.startMin,
    required this.endMin,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = _formatMinutes(startMin);
    final endStr = _formatMinutes(endMin);
    final txt1 = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final txt3 = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.permissible.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.permissible.withOpacity(isDark ? 0.10 : 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text('🌞', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.duha,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt1),
              ),
              const SizedBox(height: 2),
              Text(
                '$startStr – $endStr',
                style: TextStyle(fontSize: 12, color: txt3),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.permissible.withOpacity(isDark ? 0.10 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '2–12',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.permissible),
          ),
        ),
      ]),
    );
  }

  static String _formatMinutes(int totalMin) {
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}