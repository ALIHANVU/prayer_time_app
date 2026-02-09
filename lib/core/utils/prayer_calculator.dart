import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/prayer_api_service.dart';

enum PrayerStatus { completed, active, upcoming }

enum PrayerZone { fadila, permissible, makruh, expired }

class PrayerData {
  final String id;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final IconData icon;

  const PrayerData({
    required this.id,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.icon,
  });

  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  int get totalMinutes =>
      (endHour * 60 + endMinute) - (startHour * 60 + startMinute);

  String get durationText {
    final total = totalMinutes;
    if (total <= 0) return '--';
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0) return '${h}ч ${m}м';
    return '${m}м';
  }

  /// Фадиля — первая треть времени намаза
  double get fadilaFraction => 0.33;

  /// Допустимо — средняя треть
  double get permissibleFraction => 0.34;

  /// Макрух — последняя треть
  double get makruhFraction => 1.0 - fadilaFraction - permissibleFraction;
}

class PrayerCalculator {
  /// Текущие данные (реальные или запасные)
  static List<PrayerData> _prayers = _fallbackPrayers;
  static int _sunriseHour = 6;
  static int _sunriseMinute = 45;
  static String _hijriDate = '';

  /// Запасные данные — используются, если нет интернета
  static const List<PrayerData> _fallbackPrayers = [
    PrayerData(
      id: 'fajr',
      startHour: 5, startMinute: 12,
      endHour: 6, endMinute: 35,
      icon: Icons.nights_stay_outlined,
    ),
    PrayerData(
      id: 'dhuhr',
      startHour: 12, startMinute: 30,
      endHour: 15, endMinute: 30,
      icon: Icons.light_mode_outlined,
    ),
    PrayerData(
      id: 'asr',
      startHour: 15, startMinute: 45,
      endHour: 17, endMinute: 20,
      icon: Icons.wb_sunny_outlined,
    ),
    PrayerData(
      id: 'maghrib',
      startHour: 17, startMinute: 28,
      endHour: 18, endMinute: 40,
      icon: Icons.wb_twilight_outlined,
    ),
    PrayerData(
      id: 'isha',
      startHour: 18, startMinute: 45,
      endHour: 23, endMinute: 59,
      icon: Icons.dark_mode_outlined,
    ),
  ];

  static const Map<String, IconData> _prayerIcons = {
    'fajr': Icons.nights_stay_outlined,
    'dhuhr': Icons.light_mode_outlined,
    'asr': Icons.wb_sunny_outlined,
    'maghrib': Icons.wb_twilight_outlined,
    'isha': Icons.dark_mode_outlined,
  };

  /// Получить текущие намазы
  static List<PrayerData> get todayPrayers => _prayers;

  /// Информация о восходе
  static int get sunriseHour => _sunriseHour;
  static int get sunriseMinute => _sunriseMinute;
  static String get sunriseFormatted =>
      '${_sunriseHour.toString().padLeft(2, '0')}:${_sunriseMinute.toString().padLeft(2, '0')}';

  /// Хиджри дата
  static String get hijriDate => _hijriDate;

  /// Обновить данные от API
  /// Вызывается один раз при загрузке + когда пользователь меняет город
  static Future<bool> updateFromApi({
    required double latitude,
    required double longitude,
    int method = 14,
  }) async {
    final data = await PrayerApiService.fetchTodayTimes(
      latitude: latitude,
      longitude: longitude,
      method: method,
    );

    if (data == null) return false; // Нет интернета — используем запасные

    // Сохраняем восход
    _sunriseHour = data.sunrise.hour;
    _sunriseMinute = data.sunrise.minute;

    // Хиджри дата
    _hijriDate = data.hijriFormatted;

    // Конвертируем API данные в PrayerData
    // Конец каждого намаза = начало следующего
    final apiPrayers = data.allPrayers;
    final List<PrayerData> result = [];

    for (int i = 0; i < apiPrayers.length; i++) {
      final current = apiPrayers[i];
      int endH, endM;

      if (i < apiPrayers.length - 1) {
        // Конец = начало следующего намаза
        endH = apiPrayers[i + 1].hour;
        endM = apiPrayers[i + 1].minute;
      } else {
        // Иша заканчивается в полночь (или до Фаджра)
        endH = 23;
        endM = 59;
      }

      // Особый случай: Фаджр заканчивается с восходом
      if (current.name == 'fajr') {
        endH = data.sunrise.hour;
        endM = data.sunrise.minute;
      }

      result.add(PrayerData(
        id: current.name,
        startHour: current.hour,
        startMinute: current.minute,
        endHour: endH,
        endMinute: endM,
        icon: _prayerIcons[current.name] ?? Icons.access_time,
      ));
    }

    _prayers = result;
    debugPrint('✅ Данные обновлены: ${result.map((e) => '${e.id} ${e.startTimeFormatted}').join(', ')}');
    return true;
  }

  // === Все методы расчёта ниже работают так же, как раньше ===

  static int getActivePrayerIndex(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (int i = 0; i < _prayers.length; i++) {
      final p = _prayers[i];
      final start = p.startHour * 60 + p.startMinute;
      final end = p.endHour * 60 + p.endMinute;
      if (nowMin >= start && nowMin < end) return i;
    }
    return -1;
  }

  static double getProgress(int index, DateTime now) {
    if (index < 0) return 0.0;
    final p = _prayers[index];
    final startMin = p.startHour * 60 + p.startMinute;
    final endMin = p.endHour * 60 + p.endMinute;
    final nowMin = now.hour * 60 + now.minute + now.second / 60.0;
    return ((nowMin - startMin) / (endMin - startMin)).clamp(0.0, 1.0);
  }

  static PrayerZone getCurrentZone(int index, DateTime now) {
    if (index < 0) return PrayerZone.expired;
    final p = _prayers[index];
    final progress = getProgress(index, now);
    if (progress <= p.fadilaFraction) return PrayerZone.fadila;
    if (progress <= p.fadilaFraction + p.permissibleFraction) {
      return PrayerZone.permissible;
    }
    return PrayerZone.makruh;
  }

  static Color getZoneColor(PrayerZone zone) {
    switch (zone) {
      case PrayerZone.fadila:
        return AppColors.fadila;
      case PrayerZone.permissible:
        return AppColors.permissible;
      case PrayerZone.makruh:
        return AppColors.makruh;
      case PrayerZone.expired:
        return AppColors.missed;
    }
  }

  static String getZoneName(PrayerZone zone) {
    switch (zone) {
      case PrayerZone.fadila:
        return 'Фадиля';
      case PrayerZone.permissible:
        return 'Допустимо';
      case PrayerZone.makruh:
        return 'Макрух';
      case PrayerZone.expired:
        return 'Упущен';
    }
  }

  static String getTimeRemaining(int index, DateTime now) {
    if (index < 0) return '--:--';
    final p = _prayers[index];
    final endSec = (p.endHour * 60 + p.endMinute) * 60;
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    final rem = endSec - nowSec;
    if (rem <= 0) return '0:00';
    final h = rem ~/ 3600;
    final m = (rem % 3600) ~/ 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}';
    return '0:${m.toString().padLeft(2, '0')}';
  }

  static PrayerStatus getStatus(int prayerIndex, int activeIndex, DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    final p = _prayers[prayerIndex];
    final end = p.endHour * 60 + p.endMinute;
    if (activeIndex >= 0) {
      if (prayerIndex < activeIndex) return PrayerStatus.completed;
      if (prayerIndex == activeIndex) return PrayerStatus.active;
      return PrayerStatus.upcoming;
    }
    return nowMin >= end ? PrayerStatus.completed : PrayerStatus.upcoming;
  }

  static String getNextPrayerTime(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (var p in _prayers) {
      final start = p.startHour * 60 + p.startMinute;
      if (nowMin < start) return p.startTimeFormatted;
    }
    return _prayers.first.startTimeFormatted;
  }
}