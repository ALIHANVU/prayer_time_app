import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class PrayerCard extends StatefulWidget {
  final PrayerData prayer;
  final String localizedName;
  final PrayerStatus status;
  final PrayerZone zone;
  final bool isActive;
  final DateTime now;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.localizedName,
    required this.status,
    required this.zone,
    required this.isActive,
    required this.now,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _animCtrl.forward() : _animCtrl.reverse();
    });
  }

  // Адаптивные цвета
  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _surf2(bool d) => d ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;
  Color _detailBg(bool d) => d ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppLocalizations.of(context);

    Color accentBarColor;
    Color nameColor;
    Color timeColor;
    String statusText = '';
    Color statusColor = AppColors.textSecondaryDark;

    if (widget.isActive) {
      switch (widget.zone) {
        case PrayerZone.fadila:
          accentBarColor = AppColors.fadila;
          statusText = s.zoneFadila;
          statusColor = AppColors.fadila;
          timeColor = AppColors.fadila;
          break;
        case PrayerZone.permissible:
          accentBarColor = AppColors.fadila;
          statusText = s.zonePermissible;
          statusColor = AppColors.permissible;
          timeColor = AppColors.permissible;
          break;
        case PrayerZone.makruh:
          accentBarColor = AppColors.makruh;
          statusText = s.zoneMakruh;
          statusColor = AppColors.makruh;
          timeColor = AppColors.makruh;
          break;
        case PrayerZone.expired:
          accentBarColor = AppColors.missed;
          timeColor = _txt1(isDark);
          break;
      }
      nameColor = _txt1(isDark);
      final rem = PrayerCalculator.getTimeRemaining(
          PrayerCalculator.getActivePrayerIndex(widget.now), widget.now);
      if (statusText.isNotEmpty) {
        statusText = '$statusText · $rem ${s.timeRemaining}';
      }
    } else if (widget.status == PrayerStatus.completed) {
      accentBarColor = _txt3(isDark).withOpacity(0.25);
      nameColor = _txt3(isDark);
      timeColor = _txt3(isDark);
      statusText = s.completed;
      statusColor = _txt3(isDark);
    } else {
      accentBarColor = _surf2(isDark);
      nameColor = _txt1(isDark);
      timeColor = _txt1(isDark);
      final nowMin = widget.now.hour * 60 + widget.now.minute;
      final diff = widget.prayer.startMin - nowMin;
      if (diff > 0) {
        final h = diff ~/ 60;
        final m = diff % 60;
        statusText = h > 0
            ? '${s.forbiddenIn} $h:${m.toString().padLeft(2, '0')}'
            : '${s.forbiddenIn} $m ${s.minutes}';
      }
      statusColor = _txt3(isDark);
    }

    String emoji;
    switch (widget.prayer.id) {
      case 'fajr': emoji = '🌙'; break;
      case 'dhuhr': emoji = '🌤'; break;
      case 'asr': emoji = '🌅'; break;
      case 'maghrib': emoji = '🌇'; break;
      case 'isha': emoji = '🌙'; break;
      default: emoji = '🕌';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: widget.isActive
            ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF))
            : _surf(isDark),
        border: Border.all(
          color: _expanded
              ? AppColors.accent.withOpacity(0.15)
              : (widget.isActive ? _sep(isDark) : Colors.transparent),
          width: 1,
        ),
        boxShadow: (!isDark && widget.isActive)
            ? [BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 3, height: 38,
                    decoration: BoxDecoration(
                      color: accentBarColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: widget.isActive
                          ? [BoxShadow(color: accentBarColor.withOpacity(0.3), blurRadius: 6)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? statusColor.withOpacity(isDark ? 0.10 : 0.08)
                          : _surf2(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.localizedName,
                            style: AppTextStyles.prayerName.copyWith(
                              color: nameColor,
                              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                            )),
                        if (statusText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(statusText,
                                style: TextStyle(
                                  fontSize: 12, color: statusColor,
                                  fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
                                )),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.prayer.startTimeFormatted,
                          style: AppTextStyles.prayerTime.copyWith(color: timeColor)),
                      Text(widget.prayer.endTimeFormatted,
                          style: AppTextStyles.caption1.copyWith(color: _txt3(isDark))),
                    ],
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _txt3(isDark)),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: _buildDetail(isDark, s),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(bool isDark, AppStrings s) {
    final sunnahInfo = _getSunnahInfo(widget.prayer.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Суннаны до и после
          ...sunnahInfo.map((item) => _sunnahRow(item, isDark)),

          const SizedBox(height: 8),

          // Далиль
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(isDark ? 0.06 : 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getDalil(widget.prayer.id),
              style: TextStyle(fontSize: 11, color: AppColors.accent, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunnahRow(_SunnahItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _detailBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Иконка до/после
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: item.color.withOpacity(isDark ? 0.10 : 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          // Текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _txt1(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: _txt3(isDark),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Количество ракаатов
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.color.withOpacity(isDark ? 0.10 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.rakaat,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: item.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SunnahItem> _getSunnahInfo(String id) {
    switch (id) {
      case 'fajr':
        return [
          _SunnahItem(
            emoji: '🕌',
            title: 'Сунна до Фаджра',
            subtitle: 'Сунна муаккада. «Лучше, чем весь мир и всё, что в нём» (Муслим 725)',
            rakaat: '2',
            color: AppColors.fadila,
          ),
          _SunnahItem(
            emoji: '📖',
            title: 'Фард Фаджр',
            subtitle: 'Обязательная утренняя молитва. Читается вслух',
            rakaat: '2',
            color: AppColors.accent,
          ),
        ];
      case 'dhuhr':
        return [
          _SunnahItem(
            emoji: '🕌',
            title: 'Сунна до Зухра',
            subtitle: 'Сунна муаккада. 4 ракаата с одним салямом (ат-Тирмизи 428)',
            rakaat: '4',
            color: AppColors.fadila,
          ),
          _SunnahItem(
            emoji: '📖',
            title: 'Фард Зухр',
            subtitle: 'Обязательная полуденная молитва. Читается про себя',
            rakaat: '4',
            color: AppColors.accent,
          ),
          _SunnahItem(
            emoji: '🕌',
            title: 'Сунна после Зухра',
            subtitle: 'Сунна муаккада (ат-Тирмизи 428)',
            rakaat: '2',
            color: AppColors.permissible,
          ),
        ];
      case 'asr':
        return [
          _SunnahItem(
            emoji: '🤲',
            title: 'Сунна до Аср',
            subtitle: '«Да помилует Аллах того, кто совершил 4 ракаата до Аср» (Абу Дауд 1271). Гайр муаккада',
            rakaat: '4',
            color: AppColors.permissible,
          ),
          _SunnahItem(
            emoji: '📖',
            title: 'Фард Аср',
            subtitle: 'Обязательная послеполуденная молитва. Читается про себя',
            rakaat: '4',
            color: AppColors.accent,
          ),
        ];
      case 'maghrib':
        return [
          _SunnahItem(
            emoji: '📖',
            title: 'Фард Магриб',
            subtitle: 'Обязательная закатная молитва. Первые 2 ракаата вслух',
            rakaat: '3',
            color: AppColors.accent,
          ),
          _SunnahItem(
            emoji: '🕌',
            title: 'Сунна после Магриба',
            subtitle: 'Сунна муаккада (ат-Тирмизи 428)',
            rakaat: '2',
            color: AppColors.permissible,
          ),
        ];
      case 'isha':
        return [
          _SunnahItem(
            emoji: '📖',
            title: 'Фард Иша',
            subtitle: 'Обязательная ночная молитва. Первые 2 ракаата вслух',
            rakaat: '4',
            color: AppColors.accent,
          ),
          _SunnahItem(
            emoji: '🕌',
            title: 'Сунна после Иша',
            subtitle: 'Сунна муаккада (ат-Тирмизи 428)',
            rakaat: '2',
            color: AppColors.permissible,
          ),
          _SunnahItem(
            emoji: '🌙',
            title: 'Витр',
            subtitle: 'Сунна муаккада. Можно 1, 3, 5 или более нечётных ракаатов (Муслим 749)',
            rakaat: '1–11',
            color: AppColors.fadila,
          ),
        ];
      default:
        return [];
    }
  }

  String _getDalil(String id) {
    switch (id) {
      case 'fajr': return '📖 «Время Фаджра — от рассвета до восхода солнца» (Муслим 612)';
      case 'dhuhr': return '📖 «Время Зухра — когда солнце прошло зенит, до того как тень сравняется с длиной предмета» (Муслим 612)';
      case 'asr': return '📖 «Время Аср продолжается пока солнце не пожелтеет» (Муслим 612)';
      case 'maghrib': return '📖 «Время Магриба — пока не погаснет вечерняя заря» (Муслим 612)';
      case 'isha': return '📖 «Время Иша продолжается до середины ночи» (Муслим 612)';
      default: return '';
    }
  }
}

class _SunnahItem {
  final String emoji;
  final String title;
  final String subtitle;
  final String rakaat;
  final Color color;

  const _SunnahItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.rakaat,
    required this.color,
  });
}