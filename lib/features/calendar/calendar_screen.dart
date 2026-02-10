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
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/calendar'
            '/$_year/$_month'
            '?latitude=${AppPreferences.latitude}'
            '&longitude=${AppPreferences.longitude}'
            '&method=${AppPreferences.calculationMethod}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        final strings = AppLocalizations.of(context);
        setState(() {
          _error = '${strings.loadingError} (${response.statusCode})';
          _isLoading = false;
        });
        return;
      }

      final json = jsonDecode(response.body);
      if (json['code'] != 200) {
        final strings = AppLocalizations.of(context);
        setState(() {
          _error = strings.apiError;
          _isLoading = false;
        });
        return;
      }

      final List data = json['data'];
      final days = <_DayData>[];

      for (final item in data) {
        final timings = item['timings'] as Map<String, dynamic>;
        final greg = item['date']['gregorian'];
        final hijri = item['date']['hijri'];

        days.add(_DayData(
          day: int.parse(greg['day']),
          weekday: greg['weekday']['en'],
          hijriDay: hijri['day'],
          fajr: _cleanTime(timings['Fajr']),
          sunrise: _cleanTime(timings['Sunrise']),
          dhuhr: _cleanTime(timings['Dhuhr']),
          asr: _cleanTime(timings['Asr']),
          maghrib: _cleanTime(timings['Maghrib']),
          isha: _cleanTime(timings['Isha']),
        ));
      }

      setState(() {
        _days = days;
        _isLoading = false;
      });
    } catch (e) {
      final strings = AppLocalizations.of(context);
      setState(() {
        _error = strings.noInternet;
        _isLoading = false;
      });
    }
  }

  String _cleanTime(String time) {
    return time.split(' ').first.trim();
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) {
        _month = 1;
        _year++;
      } else if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
    _loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(strings.calendarTitle, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Text(
            '${AppPreferences.cityName}, ${AppPreferences.countryName}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),

          _buildMonthSelector(strings),
          const SizedBox(height: 16),

          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else if (_error.isNotEmpty)
            _buildError(strings)
          else if (_days != null)
              _buildTable(strings),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            '${strings.monthName(_month)} $_year',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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

  Widget _buildTable(AppStrings strings) {
    final today = DateTime.now().day;
    final isCurrentMonth =
        _month == DateTime.now().month && _year == DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.accent.withOpacity(0.08),
            ),
            headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            columnSpacing: 14,
            horizontalMargin: 12,
            columns: [
              DataColumn(label: Text(strings.day)),
              DataColumn(label: Text(strings.fajr)),
              DataColumn(label: Text(strings.sunrise)),
              DataColumn(label: Text(strings.dhuhr)),
              DataColumn(label: Text(strings.asr)),
              DataColumn(label: Text(strings.maghrib)),
              DataColumn(label: Text(strings.isha)),
            ],
            rows: _days!.map((day) {
              final isToday = isCurrentMonth && day.day == today;
              final color = isToday
                  ? AppColors.accent.withOpacity(0.06)
                  : null;
              final weight = isToday ? FontWeight.w700 : FontWeight.w400;

              return DataRow(
                color: color != null
                    ? WidgetStateProperty.all(color)
                    : null,
                cells: [
                  DataCell(Text(
                    '${day.day}',
                    style: TextStyle(
                      fontWeight: weight,
                      color: isToday ? AppColors.accent : null,
                    ),
                  )),
                  DataCell(Text(day.fajr, style: TextStyle(fontWeight: weight))),
                  DataCell(Text(day.sunrise, style: TextStyle(
                    fontWeight: weight,
                    color: AppColors.textSecondary,
                  ))),
                  DataCell(Text(day.dhuhr, style: TextStyle(fontWeight: weight))),
                  DataCell(Text(day.asr, style: TextStyle(fontWeight: weight))),
                  DataCell(Text(day.maghrib, style: TextStyle(fontWeight: weight))),
                  DataCell(Text(day.isha, style: TextStyle(fontWeight: weight))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppStrings strings) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(_error,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadCalendar,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(strings.tryAgain),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _DayData {
  final int day;
  final String weekday;
  final String hijriDay;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const _DayData({
    required this.day, required this.weekday, required this.hijriDay,
    required this.fajr, required this.sunrise, required this.dhuhr,
    required this.asr, required this.maghrib, required this.isha,
  });
}