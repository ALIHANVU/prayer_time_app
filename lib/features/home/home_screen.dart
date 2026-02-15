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

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayers = PrayerCalculator.todayPrayers;

    if (prayers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ai = PrayerCalculator.getActivePrayerIndex(_now);
    final prog = PrayerCalculator.getProgress(ai, _now);
    final zone = PrayerCalculator.getCurrentZone(ai, _now);
    final zoneColor = PrayerCalculator.getZoneColor(zone);

    final prayerNames = {
      'fajr': s.fajr, 'dhuhr': s.dhuhr, 'asr': s.asr,
      'maghrib': s.maghrib, 'isha': s.isha,
    };

    final activeName = ai >= 0 ? prayerNames[prayers[ai].id] ?? '' : '';
    final remaining = PrayerCalculator.getTimeRemaining(ai, _now);
    final timeRange = ai >= 0
        ? '${prayers[ai].startTimeFormatted} – ${prayers[ai].endTimeFormatted}'
        : '';

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ─── Заголовок ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(s.appTitle, style: AppTextStyles.largeTitle.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            )),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${AppPreferences.cityName}, ${AppPreferences.countryName}',
              style: AppTextStyles.subheadline,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDateRow(s, isDark),
          ),
          const SizedBox(height: 24),

          // ─── Баннер запретного времени ───
          if (actForbid != null)
            ForbiddenBanner(forbidden: actForbid, isActive: true, strings: s),
          if (actForbid == null && upForbid != null)
            ForbiddenBanner(
                forbidden: upForbid, isActive: false, now: _now, strings: s),

          // ─── Кольцо прогресса ───
          if (ai >= 0) ...[
            _buildProgressSection(
                activeName, remaining, timeRange, prog,
                zone, zoneColor, ff, pf, zoneName, isDark),
            const SizedBox(height: 10),
            _buildZoneLegend(s),
            const SizedBox(height: 28),
          ] else ...[
            _buildNextPrayerCard(s, isDark),
            const SizedBox(height: 28),
          ],

          // ─── Расписание ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              s.scheduleTitle.toUpperCase(),
              style: AppTextStyles.sectionHeader,
            ),
          ),
          const SizedBox(height: 10),

          // Фаджр
          _buildPrayerItem(prayers[0], prayerNames, 0, ai, zone, isDark),
          // Восход
          _buildSunriseDivider(s, isDark),
          // Остальные
          ...List.generate(prayers.length - 1, (i) =>
              _buildPrayerItem(prayers[i + 1], prayerNames, i + 1, ai, zone, isDark)),

          // Доп. отступ для плавающего навбара
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildDateRow(AppStrings s, bool isDark) {
    final mn = s.monthNameOf(_now.month);
    final wd = s.weekdayName(_now.weekday);
    final hijri = PrayerCalculator.hijriDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$wd, ${_now.day} $mn',
            style: AppTextStyles.subheadline.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        if (hijri.isNotEmpty)
          Text(hijri, style: AppTextStyles.caption1.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildProgressSection(String name, String time, String range,
      double prog, PrayerZone zone, Color zoneColor,
      double ff, double pf, String zoneName, bool isDark) {
    return Center(
      child: SizedBox(
        width: 230, height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
                size: const Size(230, 230),
                painter: ZonedProgressPainter(
                    fadilaFraction: ff, permissibleFraction: pf,
                    progress: prog, zone: zone, isDark: isDark)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTextStyles.headline.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(time, style: AppTextStyles.timerLarge.copyWith(color: zoneColor)),
                const SizedBox(height: 8),
                // Зона бейдж — iOS 26 крупнее
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: zoneColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(zoneName, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: zoneColor)),
                ),
                const SizedBox(height: 4),
                Text(range, style: AppTextStyles.caption1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneLegend(AppStrings s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(AppColors.fadila, s.zoneFadila),
        const SizedBox(width: 18),
        _legendDot(AppColors.permissible, s.zonePermissible),
        const SizedBox(width: 18),
        _legendDot(AppColors.makruh, s.zoneMakruh),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.caption1),
      ],
    );
  }

  Widget _buildNextPrayerCard(AppStrings s, bool isDark) {
    final nextName = PrayerCalculator.getNextPrayerName(_now);
    final nextTime = PrayerCalculator.getNextPrayerTime(_now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusM), // 22px
        ),
        child: Column(
          children: [
            Text(s.nextPrayer, style: AppTextStyles.footnote),
            const SizedBox(height: 6),
            Text(s.prayerName(nextName), style: AppTextStyles.title2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(nextTime, style: AppTextStyles.title1.copyWith(
                color: AppColors.accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerItem(PrayerData prayer, Map<String, String> names,
      int index, int activeIndex, PrayerZone zone, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PrayerCard(
        prayer: prayer,
        localizedName: names[prayer.id] ?? prayer.id,
        status: PrayerCalculator.getStatus(index, activeIndex, _now),
        zone: activeIndex == index ? zone : PrayerZone.expired,
        isActive: activeIndex == index,
        now: _now,
      ),
    );
  }

  Widget _buildSunriseDivider(AppStrings s, bool isDark) {
    final sr = PrayerCalculator.sunriseMinutes;
    final h = sr ~/ 60; final m = sr % 60;
    final t = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Container(height: 0.5,
              color: isDark ? AppColors.separatorDark : AppColors.separator)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${s.sunriseTitle}  $t',
                style: AppTextStyles.caption1.copyWith(
                    color: AppColors.permissible, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Container(height: 0.5,
              color: isDark ? AppColors.separatorDark : AppColors.separator)),
        ],
      ),
    );
  }
}