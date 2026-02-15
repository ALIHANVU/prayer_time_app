import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    super.key, required this.prayer, required this.localizedName,
    required this.zone, required this.progress, required this.timeRemaining,
    this.nextPrayerName, this.nextPrayerTime, required this.sunriseMinutes,
    this.activeForbidden, this.upcomingForbidden, required this.now, required this.strings,
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

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  String _prayerEmoji() {
    switch (prayer.id) {
      case 'fajr': return '🌙';
      case 'dhuhr': return '☀️';
      case 'asr': return '🌤️';
      case 'maghrib': return '🌅';
      case 'isha': return '🌃';
      default: return '🕌';
    }
  }

  String _forbiddenLocalName(ForbiddenTime f) {
    switch (f.id) {
      case 'sunrise': return strings.forbiddenSunriseName;
      case 'zenith': return strings.forbiddenZenithName;
      case 'sunset': return strings.forbiddenSunsetName;
      default: return f.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zoneColor = _zoneColor();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDark ? [AppColors.heroStartDark, AppColors.heroEndDark]
                : [AppColors.heroStartLight, AppColors.heroEndLight]),
        border: Border.all(color: _sep(isDark), width: 1),
        boxShadow: isDark ? null : [BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Stack(children: [
        Positioned(top: -60, right: -40, child: Container(width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.accent.withOpacity(isDark ? 0.12 : 0.07), Colors.transparent])))),
        Column(children: [
          // Top
          Padding(padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(strings.active.toUpperCase(), style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark), letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(_prayerEmoji(), style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(localizedName, style: AppTextStyles.heroPrayerName.copyWith(color: _txt1(isDark))),
                  ]),
                  const SizedBox(height: 3),
                  Text('${prayer.startTimeFormatted} – ${prayer.endTimeFormatted}', style: AppTextStyles.footnote.copyWith(color: _txt3(isDark))),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(timeRemaining, style: AppTextStyles.heroTimer.copyWith(color: zoneColor)),
                  const SizedBox(height: 4),
                  Text(strings.timeRemaining, style: AppTextStyles.caption2.copyWith(color: _txt3(isDark))),
                ]),
              ])),

          // Zone badge
          Padding(padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Align(alignment: Alignment.centerLeft,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: zoneColor.withOpacity(isDark ? 0.10 : 0.08), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: zoneColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(_zoneName(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: zoneColor)),
                      ])))),

          // Progress bar
          Padding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: _ProgressBar(progress: progress, isDark: isDark, strings: strings, zoneColor: zoneColor)),

          // Footer chips
          Container(margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: _sep(isDark), width: 1))),
              child: Row(children: [
                Expanded(child: _firstChip(isDark)),
                const SizedBox(width: 12),
                Expanded(child: _secondChip(context, isDark)),
              ])),
        ]),
      ]),
    );
  }

  Widget _chip({required Color bg, Color? border, required bool isDark, required Widget child}) {
    return Container(padding: const EdgeInsets.all(10), constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
            border: border != null ? Border.all(color: border) : null),
        child: child);
  }

  Widget _firstChip(bool isDark) {
    if (prayer.id == 'fajr') {
      final h = sunriseMinutes ~/ 60; final m = sunriseMinutes % 60;
      final t = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      return _chip(bg: AppColors.permissible.withOpacity(isDark ? 0.08 : 0.06), isDark: isDark,
          child: Row(children: [
            const Text('☀️', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(strings.sunriseTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.permissible)),
              const SizedBox(height: 1),
              Text(t, style: TextStyle(fontSize: 11, color: _txt3(isDark))),
            ])),
          ]));
    }

    if (activeForbidden != null) {
      return _chip(bg: AppColors.makruh.withOpacity(isDark ? 0.08 : 0.06), border: AppColors.makruh.withOpacity(0.1), isDark: isDark,
          child: Row(children: [
            const Text('⛔', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(strings.forbiddenNowTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.makruh)),
              const SizedBox(height: 1),
              Text('${_forbiddenLocalName(activeForbidden!)} · ${strings.forbiddenUntil} ${activeForbidden!.endFormatted}',
                  style: TextStyle(fontSize: 11, color: AppColors.makruh.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]));
    }

    if (upcomingForbidden != null) {
      final nowMin = now.hour * 60 + now.minute;
      final diff = upcomingForbidden!.startMin - nowMin;
      final h = diff ~/ 60; final m = diff % 60;
      final timeStr = h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '$m ${strings.minutes}';
      return _chip(bg: AppColors.permissible.withOpacity(isDark ? 0.08 : 0.06), isDark: isDark,
          child: Row(children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(strings.forbiddenSoonTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.permissible)),
              const SizedBox(height: 1),
              Text('${_forbiddenLocalName(upcomingForbidden!)} · ${strings.forbiddenIn} $timeStr',
                  style: TextStyle(fontSize: 11, color: AppColors.permissible.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]));
    }

    return _chip(bg: AppColors.accent.withOpacity(isDark ? 0.06 : 0.04), isDark: isDark,
        child: Row(children: [
          const Text('📖', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
          Expanded(child: Text(_getShortDalil(prayer.id), style: TextStyle(fontSize: 11, color: AppColors.accent, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]));
  }

  Widget _secondChip(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); _showDhikrSheet(context); },
      child: _chip(bg: AppColors.fadila.withOpacity(isDark ? 0.08 : 0.06), border: AppColors.fadila.withOpacity(0.15), isDark: isDark,
          child: Row(children: [
            const Text('📿', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(strings.adhkarTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.fadila)),
              const SizedBox(height: 1),
              Text(strings.adhkarSubtitle, style: TextStyle(fontSize: 11, color: AppColors.fadila.withOpacity(0.7))),
            ])),
            Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.fadila.withOpacity(0.5)),
          ])),
    );
  }

  void _showDhikrSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(initialChildSize: 0.75, minChildSize: 0.5, maxChildSize: 0.92,
            builder: (_, scrollCtrl) => Container(
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(children: [
                  Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 6),
                      decoration: BoxDecoration(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary, borderRadius: BorderRadius.circular(2))),
                  Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Row(children: [
                        const Text('📿', style: TextStyle(fontSize: 24)), const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(strings.adhkarAfterPrayer, style: AppTextStyles.title3.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          Text(strings.adhkarSource, style: AppTextStyles.caption1.copyWith(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary)),
                        ])),
                      ])),
                  Divider(height: 1, color: isDark ? AppColors.separatorDark : AppColors.separator),
                  Expanded(child: ListView(controller: scrollCtrl, padding: const EdgeInsets.fromLTRB(20, 16, 20, 40), children: [
                    _dhikrItem('1', strings.adhkarIstighfar, strings.adhkarIstighfarArabic, strings.adhkarIstighfarTranslit, strings.adhkarIstighfarTranslation, strings.adhkarIstighfarCount, isDark),
                    _dhikrItem('2', strings.adhkarSalam, strings.adhkarSalamArabic, strings.adhkarSalamTranslit, strings.adhkarSalamTranslation, strings.adhkarSalamCount, isDark),
                    _dhikrItem('3', strings.adhkarAyatulKursi, strings.adhkarAyatulKursiArabic, strings.adhkarAyatulKursiTranslit, strings.adhkarAyatulKursiTranslation, strings.adhkarAyatulKursiCount, isDark),
                    _dhikrItem('4', strings.adhkarTasbih, strings.adhkarTasbihArabic, strings.adhkarTasbihTranslit, strings.adhkarTasbihTranslation, strings.adhkarTasbihCount, isDark),
                    _dhikrItem('5', strings.adhkarTahmid, strings.adhkarTahmidArabic, strings.adhkarTahmidTranslit, strings.adhkarTahmidTranslation, strings.adhkarTahmidCount, isDark),
                    _dhikrItem('6', strings.adhkarTakbir, strings.adhkarTakbirArabic, strings.adhkarTakbirTranslit, strings.adhkarTakbirTranslation, strings.adhkarTakbirCount, isDark),
                    _dhikrItem('7', strings.adhkarTahlil, strings.adhkarTahlilArabic, strings.adhkarTahlilTranslit, strings.adhkarTahlilTranslation, strings.adhkarTahlilCount, isDark),
                  ])),
                ]))));
  }

  Widget _dhikrItem(String num, String title, String arabic, String translit, String translation, String count, bool isDark) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.fadila.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center, child: Text(num, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.fadila))),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Text(count, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent))),
          ]),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? AppColors.surface3Dark : AppColors.surface3Light, borderRadius: BorderRadius.circular(12)),
              child: Text(arabic, style: TextStyle(fontSize: 20, fontFamily: 'serif', height: 1.8, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  textDirection: TextDirection.rtl, textAlign: TextAlign.right)),
          const SizedBox(height: 8),
          Text(translit, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: AppColors.accent, height: 1.4)),
          const SizedBox(height: 4),
          Text(translation, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, height: 1.4)),
        ]));
  }

  String _getShortDalil(String id) {
    switch (id) {
      case 'dhuhr': return strings.dalilShortDhuhr;
      case 'asr': return strings.dalilShortAsr;
      case 'maghrib': return strings.dalilShortMaghrib;
      case 'isha': return strings.dalilShortIsha;
      default: return 'Муслим 612';
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress; final bool isDark; final AppStrings strings; final Color zoneColor;
  const _ProgressBar({required this.progress, required this.isDark, required this.strings, required this.zoneColor});

  @override
  Widget build(BuildContext context) {
    final trackColor = isDark ? AppColors.surface3Dark : AppColors.surface3Light;
    final txtColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = constraints.maxWidth;
      final dotLeft = (progress * barWidth).clamp(7.0, barWidth - 7.0);
      return Column(children: [
        SizedBox(height: 14, child: Stack(clipBehavior: Clip.none, children: [
          Positioned(top: 3, left: 0, right: 0, child: Container(height: 8,
              decoration: BoxDecoration(color: trackColor, borderRadius: BorderRadius.circular(4)))),
          Positioned(top: 3, left: 0, right: 0, child: ClipRRect(borderRadius: BorderRadius.circular(4),
              child: Container(height: 8, decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.fadila, AppColors.fadila, AppColors.permissible, AppColors.makruh, Color(0xFF991B1B)],
                      stops: [0.0, 0.35, 0.55, 0.85, 1.0]))))),
          Positioned(top: 3, right: 0, child: Container(width: (1 - progress) * barWidth, height: 8,
              decoration: BoxDecoration(color: trackColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))))),
          Positioned(top: 0, left: dotLeft - 7, child: Container(width: 14, height: 14,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: zoneColor, width: 2.5),
                  boxShadow: [BoxShadow(color: zoneColor.withOpacity(0.3), blurRadius: 8)]))),
        ])),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(strings.zoneFadila, style: TextStyle(fontSize: 10, color: txtColor)),
          Text(strings.zonePermissible, style: TextStyle(fontSize: 10, color: txtColor)),
          Text(strings.zoneMakruh, style: TextStyle(fontSize: 10, color: txtColor)),
        ]),
      ]);
    });
  }
}