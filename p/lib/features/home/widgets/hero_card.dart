import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
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
    super.key, required this.prayer, required this.localizedName,
    required this.status, required this.zone, required this.isActive, required this.now,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() { _expanded = !_expanded; _expanded ? _animCtrl.forward() : _animCtrl.reverse(); });
  }

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _surf2(bool d) => d ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  /// Иконка намаза — исламские иконки вместо эмодзи
  IconData _prayerIcon(String id) {
    switch (id) {
      case 'fajr': return FlutterIslamicIcons.crescentMoon;
      case 'dhuhr': return FlutterIslamicIcons.solidStar;
      case 'asr': return FlutterIslamicIcons.lantern;
      case 'maghrib': return FlutterIslamicIcons.solidCrescentMoon;
      case 'isha': return FlutterIslamicIcons.solidMosque;
      default: return FlutterIslamicIcons.mosque;
    }
  }

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
          accentBarColor = AppColors.fadila; statusText = s.zoneFadila; statusColor = AppColors.fadila; timeColor = AppColors.fadila; break;
        case PrayerZone.permissible:
          accentBarColor = AppColors.fadila; statusText = s.zonePermissible; statusColor = AppColors.permissible; timeColor = AppColors.permissible; break;
        case PrayerZone.makruh:
          accentBarColor = AppColors.makruh; statusText = s.zoneMakruh; statusColor = AppColors.makruh; timeColor = AppColors.makruh; break;
        case PrayerZone.expired:
          accentBarColor = AppColors.missed; timeColor = _txt1(isDark); break;
      }
      nameColor = _txt1(isDark);
      final rem = PrayerCalculator.getTimeRemaining(PrayerCalculator.getActivePrayerIndex(widget.now), widget.now);
      if (statusText.isNotEmpty) statusText = '$statusText · $rem ${s.timeRemaining}';
    } else if (widget.status == PrayerStatus.completed) {
      accentBarColor = _txt3(isDark).withOpacity(0.25); nameColor = _txt3(isDark); timeColor = _txt3(isDark);
      statusText = s.completed; statusColor = _txt3(isDark);
    } else {
      accentBarColor = _surf2(isDark); nameColor = _txt1(isDark); timeColor = _txt1(isDark);
      final nowMin = widget.now.hour * 60 + widget.now.minute;
      final diff = widget.prayer.startMin - nowMin;
      if (diff > 0) {
        final h = diff ~/ 60; final m = diff % 60;
        statusText = h > 0 ? '${s.forbiddenIn} $h:${m.toString().padLeft(2, '0')}' : '${s.forbiddenIn} $m ${s.minutes}';
      }
      statusColor = _txt3(isDark);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: widget.isActive ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF)) : _surf(isDark),
        border: Border.all(color: _expanded ? AppColors.accent.withOpacity(0.15) : (widget.isActive ? _sep(isDark) : Colors.transparent), width: 1),
        boxShadow: (!isDark && widget.isActive) ? [BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))] : null,
      ),
      child: Column(children: [
        GestureDetector(onTap: _toggle, behavior: HitTestBehavior.opaque,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(width: 3, height: 38,
                      decoration: BoxDecoration(color: accentBarColor, borderRadius: BorderRadius.circular(2),
                          boxShadow: widget.isActive ? [BoxShadow(color: accentBarColor.withOpacity(0.3), blurRadius: 6)] : null)),
                  const SizedBox(width: 14),
                  Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: widget.isActive ? statusColor.withOpacity(isDark ? 0.10 : 0.08) : _surf2(isDark),
                          borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Icon(
                        _prayerIcon(widget.prayer.id),
                        size: 20,
                        color: widget.isActive
                            ? statusColor
                            : (widget.status == PrayerStatus.completed ? _txt3(isDark) : _txt1(isDark)),
                      )),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.localizedName, style: AppTextStyles.prayerName.copyWith(
                        color: nameColor, fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500)),
                    if (statusText.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 1),
                          child: Text(statusText, style: TextStyle(fontSize: 12, color: statusColor,
                              fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400))),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(widget.prayer.startTimeFormatted, style: AppTextStyles.prayerTime.copyWith(color: timeColor)),
                    Text(widget.prayer.endTimeFormatted, style: AppTextStyles.caption1.copyWith(color: _txt3(isDark))),
                  ]),
                  const SizedBox(width: 10),
                  AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _txt3(isDark))),
                ]))),
        SizeTransition(sizeFactor: _expandAnim, child: _buildDetail(isDark, AppLocalizations.of(context))),
      ]),
    );
  }

  Widget _buildDetail(bool isDark, AppStrings s) {
    final sunnahInfo = _getSunnahInfo(widget.prayer.id, s);
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(children: [
          ...sunnahInfo.map((item) => _sunnahRow(item, isDark)),
          const SizedBox(height: 8),
          Container(width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(isDark ? 0.06 : 0.04), borderRadius: BorderRadius.circular(10)),
              child: Text(_getDalil(widget.prayer.id, s), style: TextStyle(fontSize: 11, color: AppColors.accent, height: 1.4))),
        ]));
  }

  Widget _sunnahRow(_SunnahItem item, bool isDark) {
    return Container(
        margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: item.color.withOpacity(isDark ? 0.10 : 0.08), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(
                item.isFard ? FlutterIslamicIcons.solidKaaba : FlutterIslamicIcons.mosque,
                size: 18,
                color: item.color,
              )),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _txt1(isDark))),
            const SizedBox(height: 2),
            Text(item.subtitle, style: TextStyle(fontSize: 11, color: _txt3(isDark), height: 1.3)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: item.color.withOpacity(isDark ? 0.10 : 0.08), borderRadius: BorderRadius.circular(8)),
              child: Text(item.rakaat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: item.color))),
        ]));
  }

  List<_SunnahItem> _getSunnahInfo(String id, AppStrings s) {
    switch (id) {
      case 'fajr': return [
        _SunnahItem(title: s.sunnahFajrBefore, subtitle: s.sunnahFajrBeforeDesc, rakaat: '2', color: AppColors.fadila, isFard: false),
        _SunnahItem(title: s.fardFajr, subtitle: s.fardFajrDesc, rakaat: '2', color: AppColors.accent, isFard: true),
      ];
      case 'dhuhr': return [
        _SunnahItem(title: s.sunnahDhuhrBefore, subtitle: s.sunnahDhuhrBeforeDesc, rakaat: '4', color: AppColors.fadila, isFard: false),
        _SunnahItem(title: s.fardDhuhr, subtitle: s.fardDhuhrDesc, rakaat: '4', color: AppColors.accent, isFard: true),
        _SunnahItem(title: s.sunnahDhuhrAfter, subtitle: s.sunnahDhuhrAfterDesc, rakaat: '2', color: AppColors.permissible, isFard: false),
      ];
      case 'asr': return [
        _SunnahItem(title: s.sunnahAsrBefore, subtitle: s.sunnahAsrBeforeDesc, rakaat: '4', color: AppColors.permissible, isFard: false),
        _SunnahItem(title: s.fardAsr, subtitle: s.fardAsrDesc, rakaat: '4', color: AppColors.accent, isFard: true),
      ];
      case 'maghrib': return [
        _SunnahItem(title: s.fardMaghrib, subtitle: s.fardMaghribDesc, rakaat: '3', color: AppColors.accent, isFard: true),
        _SunnahItem(title: s.sunnahMaghribAfter, subtitle: s.sunnahMaghribAfterDesc, rakaat: '2', color: AppColors.permissible, isFard: false),
      ];
      case 'isha': return [
        _SunnahItem(title: s.fardIsha, subtitle: s.fardIshaDesc, rakaat: '4', color: AppColors.accent, isFard: true),
        _SunnahItem(title: s.sunnahIshaAfter, subtitle: s.sunnahIshaAfterDesc, rakaat: '2', color: AppColors.permissible, isFard: false),
        _SunnahItem(title: s.witr, subtitle: s.witrDesc, rakaat: '1–11', color: AppColors.fadila, isFard: false),
      ];
      default: return [];
    }
  }

  String _getDalil(String id, AppStrings s) {
    switch (id) {
      case 'fajr': return s.dalilFajr;
      case 'dhuhr': return s.dalilDhuhr;
      case 'asr': return s.dalilAsr;
      case 'maghrib': return s.dalilMaghrib;
      case 'isha': return s.dalilIsha;
      default: return '';
    }
  }
}

class _SunnahItem {
  final String title;
  final String subtitle;
  final String rakaat;
  final Color color;
  final bool isFard;
  const _SunnahItem({required this.title, required this.subtitle, required this.rakaat, required this.color, required this.isFard});
}