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
                    Expanded(child: _firstChip(isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _secondChip(context, isDark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Первый чип: Восход (только для Фаджра) или запретное время или далиль
  Widget _firstChip(bool isDark) {
    // Для Фаджра — показываем восход
    if (prayer.id == 'fajr') {
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

    // Для других намазов — запретное время (если есть)
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

    // Далиль намаза если нет запретного
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📖', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getShortDalil(prayer.id),
              style: TextStyle(fontSize: 11, color: AppColors.accent, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Второй чип: кнопка «Зикр» — открывает список азкаров после намаза
  Widget _secondChip(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDhikrSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.fadila.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.fadila.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            const Text('📿', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Азкары',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.fadila)),
                  const SizedBox(height: 1),
                  Text('после намаза',
                      style: TextStyle(fontSize: 11, color: AppColors.fadila.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.fadila.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showDhikrSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Ручка
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Заголовок
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Row(
                  children: [
                    const Text('📿', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Азкары после намаза',
                              style: AppTextStyles.title3.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              )),
                          Text('Муслим 597, аль-Бухари 843',
                              style: AppTextStyles.caption1.copyWith(
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.separatorDark : AppColors.separator),
              // Контент
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    _dhikrItem('1', 'Истигфар', 'أَسْتَغْفِرُ ٱللَّهَ', 'Астагфиру-Ллах',
                        'Прошу прощения у Аллаха', '3 раза', isDark),
                    _dhikrItem('2', 'Ас-Салям', 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
                        'Аллахумма Анта-с-Салям ва минка-с-салям, табаракта йа За-ль-джаляли ва-ль-икрам',
                        'О Аллах, Ты — Мир, и от Тебя — мир. Благословен Ты, о Обладатель величия и щедрости',
                        '1 раз (Муслим 591)', isDark),
                    _dhikrItem('3', 'Аятуль-Курси', 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ...',
                        'Аллаху ля иляха илля Хуваль-Хаййуль-Каййум...',
                        'Аят Трона (2:255). Кто прочтёт его после намаза — только смерть отделяет его от Рая',
                        '1 раз (ан-Насаи)', isDark),
                    _dhikrItem('4', 'Тасбих', 'سُبْحَانَ ٱللَّهِ', 'Субхана-Ллах',
                        'Пречист Аллах', '33 раза', isDark),
                    _dhikrItem('5', 'Тахмид', 'ٱلْحَمْدُ لِلَّهِ', 'Аль-хамду ли-Ллях',
                        'Хвала Аллаху', '33 раза', isDark),
                    _dhikrItem('6', 'Такбир', 'ٱللَّهُ أَكْبَرُ', 'Аллаху Акбар',
                        'Аллах Велик', '33 раза', isDark),
                    _dhikrItem('7', 'Тахлиль', 'لَا إِلَٰهَ إِلَّا ٱللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ وَلَهُ ٱلْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
                        'Ля иляха илля-Ллаху вахдаху ля шарика лях, ляхуль-мульку ва ляхуль-хамду ва хува аля кулли шайин кадир',
                        'Нет бога кроме Аллаха Единого, нет Ему сотоварища. Ему принадлежит власть и хвала, и Он над всякой вещью мощен',
                        '1 раз — до 100 (Муслим 597)', isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dhikrItem(String num, String title, String arabic, String translit,
      String translation, String count, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: AppColors.fadila.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(num, style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.fadila)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(count, style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Арабский текст
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(arabic, style: TextStyle(
              fontSize: 20, fontFamily: 'serif', height: 1.8,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ), textDirection: TextDirection.rtl, textAlign: TextAlign.right),
          ),
          const SizedBox(height: 8),
          // Транслитерация
          Text(translit, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic,
              color: AppColors.accent, height: 1.4)),
          const SizedBox(height: 4),
          // Перевод
          Text(translation, style: TextStyle(
              fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4)),
        ],
      ),
    );
  }

  String _getShortDalil(String id) {
    switch (id) {
      case 'dhuhr': return 'Муслим 612: до начала Аср';
      case 'asr': return 'Муслим 612: до пожелтения солнца';
      case 'maghrib': return 'Муслим 612: до исчезновения зари';
      case 'isha': return 'Муслим 612: до середины ночи';
      default: return 'Муслим 612';
    }
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