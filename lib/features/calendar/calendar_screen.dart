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
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/calendar/$_year/$_month'
            '?latitude=${AppPreferences.latitude}'
            '&longitude=${AppPreferences.longitude}'
            '&method=${AppPreferences.calculationMethod}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        final s = AppLocalizations.of(context);
        setState(() { _error = '${s.loadingError} (${response.statusCode})'; _isLoading = false; });
        return;
      }
      final json = jsonDecode(response.body);
      if (json['code'] != 200) {
        final s = AppLocalizations.of(context);
        setState(() { _error = s.apiError; _isLoading = false; });
        return;
      }
      final List data = json['data'];
      final days = <_DayData>[];
      for (final item in data) {
        final t = item['timings'] as Map<String, dynamic>;
        final g = item['date']['gregorian'];
        days.add(_DayData(
          day: int.parse(g['day']),
          fajr: _clean(t['Fajr']), sunrise: _clean(t['Sunrise']),
          dhuhr: _clean(t['Dhuhr']), asr: _clean(t['Asr']),
          maghrib: _clean(t['Maghrib']), isha: _clean(t['Isha']),
        ));
      }
      setState(() { _days = days; _isLoading = false; });
    } catch (e) {
      final s = AppLocalizations.of(context);
      setState(() { _error = s.noInternet; _isLoading = false; });
    }
  }

  String _clean(String t) => t.split(' ').first.trim();

  void _changeMonth(int d) {
    setState(() {
      _month += d;
      if (_month > 12) { _month = 1; _year++; }
      else if (_month < 1) { _month = 12; _year--; }
    });
    _loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(s.calendarTitle, style: AppTextStyles.largeTitle.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            )),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${AppPreferences.cityName}, ${AppPreferences.countryName}',
              style: AppTextStyles.subheadline,
            ),
          ),
          const SizedBox(height: 16),

          // Переключатель месяца
          _buildMonthSelector(s, isDark),
          const SizedBox(height: 16),

          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error.isNotEmpty)
            _buildError(s, isDark)
          else if (_days != null)
              _buildTable(s, isDark),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(AppStrings s, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.accent,
          ),
          Text(
            '${s.monthName(_month)} $_year',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(AppStrings s, bool isDark) {
    final today = DateTime.now().day;
    final isCurrentMonth = _month == DateTime.now().month && _year == DateTime.now().year;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppColors.radiusS),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.accent.withOpacity(0.06),
            ),
            headingTextStyle: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
            dataTextStyle: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            columnSpacing: 14,
            horizontalMargin: 12,
            columns: [
              DataColumn(label: Text(s.day)),
              DataColumn(label: Text(s.fajr)),
              DataColumn(label: Text(s.sunrise)),
              DataColumn(label: Text(s.dhuhr)),
              DataColumn(label: Text(s.asr)),
              DataColumn(label: Text(s.maghrib)),
              DataColumn(label: Text(s.isha)),
            ],
            rows: _days!.map((d) {
              final isToday = isCurrentMonth && d.day == today;
              return DataRow(
                color: isToday ? WidgetStateProperty.all(AppColors.accent.withOpacity(0.06)) : null,
                cells: [
                  DataCell(Text('${d.day}', style: TextStyle(
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday ? AppColors.accent : null,
                  ))),
                  DataCell(Text(d.fajr)),
                  DataCell(Text(d.sunrise, style: TextStyle(color: AppColors.textSecondary))),
                  DataCell(Text(d.dhuhr)),
                  DataCell(Text(d.asr)),
                  DataCell(Text(d.maghrib)),
                  DataCell(Text(d.isha)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppStrings s, bool isDark) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(_error, style: AppTextStyles.subheadline),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadCalendar,
              child: Text(s.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayData {
  final int day;
  final String fajr, sunrise, dhuhr, asr, maghrib, isha;
  const _DayData({
    required this.day, required this.fajr, required this.sunrise,
    required this.dhuhr, required this.asr, required this.maghrib, required this.isha,
  });
}