import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/app_preferences.dart';
import '../../core/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<_DayData>? _days;
  bool _isLoading = true;
  String _error = '';
  late int _month, _year;

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = n.month;
    _year = n.year;
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final url = Uri.parse(
          'https://api.aladhan.com/v1/calendar/$_year/$_month'
              '?latitude=${AppPreferences.latitude}'
              '&longitude=${AppPreferences.longitude}'
              '&method=${AppPreferences.calculationMethod}');
      final r = await http.get(url).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) {
        setState(() { _error = '${AppLocalizations.of(context).loadingError} (${r.statusCode})'; _isLoading = false; });
        return;
      }
      final j = jsonDecode(r.body);
      if (j['code'] != 200) {
        setState(() { _error = AppLocalizations.of(context).apiError; _isLoading = false; });
        return;
      }
      final List data = j['data'];
      final days = data.map((i) {
        final t = i['timings'] as Map<String, dynamic>;
        final g = i['date']['gregorian'];
        return _DayData(
          day: int.parse(g['day']),
          weekday: g['weekday']?['en'] ?? '',
          fajr: _c(t['Fajr']),
          sunrise: _c(t['Sunrise']),
          dhuhr: _c(t['Dhuhr']),
          asr: _c(t['Asr']),
          maghrib: _c(t['Maghrib']),
          isha: _c(t['Isha']),
        );
      }).toList();
      setState(() { _days = days; _isLoading = false; });
    } catch (_) {
      setState(() { _error = AppLocalizations.of(context).noInternet; _isLoading = false; });
    }
  }

  String _c(String t) => t.split(' ').first.trim();

  void _chg(int d) {
    setState(() {
      _month += d;
      if (_month > 12) { _month = 1; _year++; }
      else if (_month < 1) { _month = 12; _year--; }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Заголовок — единый стиль
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.calendarTitle, style: AppTextStyles.largeTitle.copyWith(color: _txt1(isDark))),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${AppPreferences.cityName}, ${AppPreferences.countryName}',
              style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark)),
            ),
          ),

          const SizedBox(height: 20),

          // Hero-карточка навигации по месяцам
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
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
              boxShadow: isDark ? null : [
                BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80, right: -60,
                  child: Container(
                    width: 180, height: 180,
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.calendarTitle.toUpperCase(),
                                style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark), letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Text('📅', style: TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Text(
                                    s.monthName(_month),
                                    style: AppTextStyles.heroPrayerName.copyWith(color: _txt1(isDark)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('$_year', style: AppTextStyles.footnote.copyWith(color: _txt3(isDark))),
                            ],
                          ),
                        ),
                        // Навигация
                        Row(
                          children: [
                            _navBtn(Icons.chevron_left_rounded, () => _chg(-1), isDark),
                            const SizedBox(width: 8),
                            _navBtn(Icons.chevron_right_rounded, () => _chg(1), isDark),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Контент
          if (_isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else if (_error.isNotEmpty)
            _errWidget(s, isDark)
          else if (_days != null)
              _daysList(s, isDark),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _navBtn(IconData ic, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(ic, color: AppColors.accent, size: 24),
      ),
    );
  }

  /// Карточки дней — в стиле prayer_card
  Widget _daysList(AppStrings s, bool isDark) {
    final today = DateTime.now().day;
    final isCurrent = _month == DateTime.now().month && _year == DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _days!.map((d) {
          final isToday = isCurrent && d.day == today;
          return _dayCard(d, s, isDark, isToday);
        }).toList(),
      ),
    );
  }

  Widget _dayCard(_DayData d, AppStrings s, bool isDark, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isToday
            ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF))
            : _surf(isDark),
        border: Border.all(
          color: isToday ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
          width: 1,
        ),
        boxShadow: (!isDark && isToday) ? [
          BoxShadow(color: AppColors.accent.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ] : null,
      ),
      child: Column(
        children: [
          // Заголовок дня
          Row(
            children: [
              Container(
                width: 3, height: 32,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isToday ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 6)] : null,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.accent.withOpacity(isDark ? 0.12 : 0.10)
                      : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: isToday ? AppColors.accent : _txt1(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isToday ? s.today : '${d.day} ${s.monthNameOf(_month)}',
                  style: TextStyle(
                    fontSize: 14, fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    color: isToday ? AppColors.accent : _txt2(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Сетка времён — 2 ряда по 3
          Row(
            children: [
              _timeChip(s.fajr, d.fajr, '🌙', isDark),
              const SizedBox(width: 6),
              _timeChip(s.sunrise, d.sunrise, '☀️', isDark, muted: true),
              const SizedBox(width: 6),
              _timeChip(s.dhuhr, d.dhuhr, '🌤️', isDark),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _timeChip(s.asr, d.asr, '🌅', isDark),
              const SizedBox(width: 6),
              _timeChip(s.maghrib, d.maghrib, '🌇', isDark),
              const SizedBox(width: 6),
              _timeChip(s.isha, d.isha, '🌃', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, String time, String emoji, bool isDark, {bool muted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w500,
                    color: muted ? _txt3(isDark) : _txt3(isDark),
                  )),
                  Text(time, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: muted ? _txt3(isDark) : _txt1(isDark),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errWidget(AppStrings s, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surf(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sep(isDark)),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.cloud_off_rounded, size: 28, color: _txt3(isDark)),
          ),
          const SizedBox(height: 16),
          Text(_error, style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark)), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(s.tryAgain, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayData {
  final int day;
  final String weekday;
  final String fajr, sunrise, dhuhr, asr, maghrib, isha;
  const _DayData({
    required this.day, this.weekday = '',
    required this.fajr, required this.sunrise, required this.dhuhr,
    required this.asr, required this.maghrib, required this.isha,
  });
}