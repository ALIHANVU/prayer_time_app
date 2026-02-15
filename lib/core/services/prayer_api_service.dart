import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Модель данных — время одного намаза от API
class ApiPrayerTime {
  final String name;
  final int hour;
  final int minute;

  const ApiPrayerTime({
    required this.name,
    required this.hour,
    required this.minute,
  });

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Полные данные на один день
class DayPrayerTimes {
  final ApiPrayerTime fajr;
  final ApiPrayerTime sunrise;
  final ApiPrayerTime dhuhr;
  final ApiPrayerTime asr;
  final ApiPrayerTime maghrib;
  final ApiPrayerTime isha;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;

  const DayPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
  });

  List<ApiPrayerTime> get allPrayers => [fajr, dhuhr, asr, maghrib, isha];

  String get hijriFormatted => '$hijriDate $hijriMonth $hijriYear г.х.';
}

/// Сервис для загрузки данных с AlAdhan API
class PrayerApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  static Future<DayPrayerTimes?> fetchTodayTimes({
    required double latitude,
    required double longitude,
    int method = 14,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      final url = Uri.parse(
        '$_baseUrl/timings/$dateStr'
            '?latitude=$latitude'
            '&longitude=$longitude'
            '&method=$method',
      );

      debugPrint('🕌 Загрузка: $url');

      // Таймаут 5 секунд — если нет интернета, не будем ждать долго
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );

      debugPrint('🕌 Ответ: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ HTTP ошибка: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body);

      if (json['code'] != 200) {
        debugPrint('❌ API ошибка: ${json['status']}');
        return null;
      }

      final timings = json['data']['timings'] as Map<String, dynamic>;
      final hijri = json['data']['date']['hijri'];

      return DayPrayerTimes(
        fajr: _parseTime('fajr', timings['Fajr']),
        sunrise: _parseTime('sunrise', timings['Sunrise']),
        dhuhr: _parseTime('dhuhr', timings['Dhuhr']),
        asr: _parseTime('asr', timings['Asr']),
        maghrib: _parseTime('maghrib', timings['Maghrib']),
        isha: _parseTime('isha', timings['Isha']),
        hijriDate: '${hijri['day']} ',
        hijriMonth: hijri['month']['ar'] ?? hijri['month']['en'],
        hijriYear: hijri['year'],
      );
    } catch (e) {
      debugPrint('❌ Ошибка загрузки: $e');
      return null;
    }
  }

  static ApiPrayerTime _parseTime(String name, String timeStr) {
    final clean = timeStr.split(' ').first.trim();
    final parts = clean.split(':');
    return ApiPrayerTime(
      name: name,
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}