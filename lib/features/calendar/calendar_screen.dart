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
  Color _surf2(bool d) => d ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  @override
  void initState() { super.initState(); final n = DateTime.now(); _month = n.month; _year = n.year; _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final url = Uri.parse('https://api.aladhan.com/v1/calendar/$_year/$_month?latitude=${AppPreferences.latitude}&longitude=${AppPreferences.longitude}&method=${AppPreferences.calculationMethod}');
      final r = await http.get(url).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) { setState(() { _error = '${AppLocalizations.of(context).loadingError} (${r.statusCode})'; _isLoading = false; }); return; }
      final j = jsonDecode(r.body);
      if (j['code'] != 200) { setState(() { _error = AppLocalizations.of(context).apiError; _isLoading = false; }); return; }
      final List data = j['data'];
      final days = data.map((i) { final t = i['timings'] as Map<String, dynamic>; final g = i['date']['gregorian'];
      return _DayData(day: int.parse(g['day']), fajr: _c(t['Fajr']), sunrise: _c(t['Sunrise']), dhuhr: _c(t['Dhuhr']), asr: _c(t['Asr']), maghrib: _c(t['Maghrib']), isha: _c(t['Isha']));
      }).toList();
      setState(() { _days = days; _isLoading = false; });
    } catch (_) { setState(() { _error = AppLocalizations.of(context).noInternet; _isLoading = false; }); }
  }

  String _c(String t) => t.split(' ').first.trim();
  void _chg(int d) { setState(() { _month += d; if (_month > 12) { _month = 1; _year++; } else if (_month < 1) { _month = 12; _year--; } }); _load(); }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(s.calendarTitle, style: AppTextStyles.largeTitle.copyWith(color: _txt1(isDark)))),
        const SizedBox(height: 2),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('${AppPreferences.cityName}, ${AppPreferences.countryName}', style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark)))),
        const SizedBox(height: 16),
        // Month nav
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: _surf(isDark), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _navBtn(Icons.chevron_left_rounded, () => _chg(-1), isDark),
            Text('${s.monthName(_month)} $_year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _txt1(isDark))),
            _navBtn(Icons.chevron_right_rounded, () => _chg(1), isDark),
          ]),
        ),
        const SizedBox(height: 16),
        if (_isLoading) const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        else if (_error.isNotEmpty) _errW(s, isDark)
        else if (_days != null) _table(s, isDark),
        const SizedBox(height: 120),
      ]),
    );
  }

  Widget _navBtn(IconData ic, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Container(
      width: 36, height: 36, decoration: BoxDecoration(color: _surf2(isDark), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center, child: Icon(ic, color: AppColors.accent, size: 22),
    ));
  }

  Widget _table(AppStrings s, bool isDark) {
    final today = DateTime.now().day;
    final cur = _month == DateTime.now().month && _year == DateTime.now().year;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: _surf(isDark), borderRadius: BorderRadius.circular(18), border: Border.all(color: _sep(isDark))),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, physics: const ClampingScrollPhysics(),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.accent.withOpacity(0.06)),
          headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent, letterSpacing: 0.5),
          dataTextStyle: TextStyle(fontSize: 13, color: _txt2(isDark), fontFeatures: const [FontFeature.tabularFigures()]),
          columnSpacing: 14, horizontalMargin: 12,
          columns: [DataColumn(label: Text(s.day)), DataColumn(label: Text(s.fajr)), DataColumn(label: Text(s.sunrise)),
            DataColumn(label: Text(s.dhuhr)), DataColumn(label: Text(s.asr)), DataColumn(label: Text(s.maghrib)), DataColumn(label: Text(s.isha))],
          rows: _days!.map((d) {
            final isT = cur && d.day == today;
            return DataRow(
              color: isT ? WidgetStateProperty.all(AppColors.accent.withOpacity(0.06)) : null,
              cells: [
                DataCell(Text('${d.day}', style: TextStyle(fontWeight: isT ? FontWeight.w700 : FontWeight.w400, color: isT ? AppColors.accent : null))),
                DataCell(Text(d.fajr)), DataCell(Text(d.sunrise, style: TextStyle(color: _txt3(isDark)))),
                DataCell(Text(d.dhuhr)), DataCell(Text(d.asr)), DataCell(Text(d.maghrib)), DataCell(Text(d.isha)),
              ],
            );
          }).toList(),
        ),
      )),
    );
  }

  Widget _errW(AppStrings s, bool isDark) {
    return SizedBox(height: 200, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, size: 40, color: _txt3(isDark)),
      const SizedBox(height: 12), Text(_error, style: AppTextStyles.subheadline),
      const SizedBox(height: 12), TextButton(onPressed: _load, child: Text(s.tryAgain)),
    ])));
  }
}

class _DayData {
  final int day; final String fajr, sunrise, dhuhr, asr, maghrib, isha;
  const _DayData({required this.day, required this.fajr, required this.sunrise, required this.dhuhr, required this.asr, required this.maghrib, required this.isha});
}