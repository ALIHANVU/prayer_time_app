import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class HeroCard extends StatelessWidget {
  final PrayerData prayer;
  final String localizedName;
  final PrayerZone zone;
  final double progress;
  final String timeRemaining;
  final String? nextPrayerName;
  final String? nextPrayerTime;
  final int sunriseMinutes;
  final ForbiddenTime? activeForbidden;
  final ForbiddenTime? upcomingForbidden;
  final DateTime now;
  final AppStrings strings;

  const HeroCard({
    super.key,
    required this.prayer,
    required this.localizedName,
    required this.zone,
    required this.progress,
    required this.timeRemaining,
    this.nextPrayerName,
    this.nextPrayerTime,
    required this.sunriseMinutes,
    this.activeForbidden,
    this.upcomingForbidden,
    required this.now,
    required this.strings,
  });

  Color _zoneColor() => PrayerCalculator.getZoneColor(zone);

  String _zoneName() {
    switch (zone) {
      case PrayerZone.fadila: return strings.zoneFadila;
      case PrayerZone.permissible: return strings.zonePermissible;
      case PrayerZone.makruh: return strings.zoneMakruh;
      case PrayerZone.expired: return strings.zoneMissed;
    }
  }

  // Адаптивные цвета
  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf3(bool d) => d ? AppColors.surface3Dark : AppColors.surface3Light;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;
  Color _chipBg(bool d) => d ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.04);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zoneColor = _zoneColor();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
      child: Stack(
        children: [
          // Glow
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

          Column(
            children: [
              // ─── Top ───
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.active.toUpperCase(),
                            style: AppTextStyles.sectionHeader.copyWith(
                              color: _txt3(isDark),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizedName,
                            style: AppTextStyles.heroPrayerName.copyWith(
                              color: _txt1(isDark),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${prayer.startTimeFormatted} – ${prayer.endTimeFormatted}',
                            style: AppTextStyles.footnote.copyWith(
                              color: _txt3(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeRemaining,
                          style: AppTextStyles.heroTimer.copyWith(
                            color: zoneColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.timeRemaining,
                          style: AppTextStyles.caption2.copyWith(
                            color: _txt3(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Zone badge ───
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: zoneColor.withOpacity(isDark ? 0.10 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: zoneColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _zoneName(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: zoneColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Progress bar ───
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: _ProgressBar(
                  progress: progress,
                  isDark: isDark,
                  strings: strings,
                  zoneColor: zoneColor,
                ),
              ),

              // ─── Footer chips ───
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: _sep(isDark), width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(child: _sunriseChip(isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _secondChip(isDark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sunriseChip(bool isDark) {
    final h = sunriseMinutes ~/ 60;
    final m = sunriseMinutes % 60;
    final t = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _chipBg(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.sunriseTitle,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.permissible)),
                const SizedBox(height: 1),
                Text(t, style: TextStyle(fontSize: 11, color: _txt3(isDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondChip(bool isDark) {
    if (activeForbidden != null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.makruh.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.makruh.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Text('⛔', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.forbiddenActive,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.makruh)),
                  const SizedBox(height: 1),
                  Text('${strings.forbiddenUntil} ${activeForbidden!.endFormatted}',
                      style: TextStyle(fontSize: 11, color: AppColors.makruh.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (upcomingForbidden != null) {
      final nowMin = now.hour * 60 + now.minute;
      final diff = upcomingForbidden!.startMin - nowMin;
      final h = diff ~/ 60;
      final m = diff % 60;
      final timeStr = h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '$m ${strings.minutes}';

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.permissible.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.forbiddenSoon,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.permissible)),
                  const SizedBox(height: 1),
                  Text('${strings.forbiddenIn} $timeStr',
                      style: TextStyle(fontSize: 11, color: AppColors.permissible.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _chipBg(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🕐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${strings.next}: ${strings.prayerName(nextPrayerName ?? '')}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.accent),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(nextPrayerTime ?? '',
                    style: TextStyle(fontSize: 11, color: _txt3(isDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Градиентная шкала прогресса
class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool isDark;
  final AppStrings strings;
  final Color zoneColor;

  const _ProgressBar({
    required this.progress,
    required this.isDark,
    required this.strings,
    required this.zoneColor,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = isDark ? AppColors.surface3Dark : AppColors.surface3Light;
    final txtColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final dotLeft = (progress * barWidth).clamp(7.0, barWidth - 7.0);

        return Column(
          children: [
            SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Positioned(
                    top: 3, left: 0, right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Gradient fill
                  Positioned(
                    top: 3, left: 0, right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.fadila,
                              AppColors.fadila,
                              AppColors.permissible,
                              AppColors.makruh,
                              Color(0xFF991B1B),
                            ],
                            stops: [0.0, 0.35, 0.55, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Mask
                  Positioned(
                    top: 3,
                    right: 0,
                    child: Container(
                      width: (1 - progress) * barWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Dot
                  Positioned(
                    top: 0,
                    left: dotLeft - 7,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: zoneColor, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: zoneColor.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.zoneFadila, style: TextStyle(fontSize: 10, color: txtColor)),
                Text(strings.zonePermissible, style: TextStyle(fontSize: 10, color: txtColor)),
                Text(strings.zoneMakruh, style: TextStyle(fontSize: 10, color: txtColor)),
              ],
            ),
          ],
        );
      },
    );
  }
}