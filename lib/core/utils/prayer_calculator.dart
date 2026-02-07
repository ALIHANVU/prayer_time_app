import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PrayerStatus { completed, active, upcoming }

enum PrayerZone { fadila, permissible, makruh, expired }

class PrayerData {
  final String id;
  final int startHour;
  final int startMinute;
  final int fadilaEndHour;
  final int fadilaEndMinute;
  final int permissibleEndHour;
  final int permissibleEndMinute;
  final int endHour;
  final int endMinute;
  final IconData icon;

  const PrayerData({
    required this.id,
    required this.startHour, required this.startMinute,
    required this.fadilaEndHour, required this.fadilaEndMinute,
    required this.permissibleEndHour, required this.permissibleEndMinute,
    required this.endHour, required this.endMinute,
    required this.icon,
  });

  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  int get totalMinutes => (endHour * 60 + endMinute) - (startHour * 60 + startMinute);

  String get durationText {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0) return '${h}ч ${m}м';
    return '${m}м';
  }

  double get fadilaFraction {
    final fadilaMin = (fadilaEndHour * 60 + fadilaEndMinute) - (startHour * 60 + startMinute);
    return fadilaMin / totalMinutes;
  }

  double get permissibleFraction {
    final permMin = (permissibleEndHour * 60 + permissibleEndMinute) - (fadilaEndHour * 60 + fadilaEndMinute);
    return permMin / totalMinutes;
  }

  double get makruhFraction => 1.0 - fadilaFraction - permissibleFraction;
}

class PrayerCalculator {
  static const List<PrayerData> todayPrayers = [
    PrayerData(id: 'fajr', startHour: 5, startMinute: 12,
        fadilaEndHour: 5, fadilaEndMinute: 50,
        permissibleEndHour: 6, permissibleEndMinute: 15,
        endHour: 6, endMinute: 35, icon: Icons.nights_stay_outlined),
    PrayerData(id: 'dhuhr', startHour: 12, startMinute: 30,
        fadilaEndHour: 13, fadilaEndMinute: 30,
        permissibleEndHour: 14, permissibleEndMinute: 45,
        endHour: 15, endMinute: 30, icon: Icons.light_mode_outlined),
    PrayerData(id: 'asr', startHour: 15, startMinute: 45,
        fadilaEndHour: 16, fadilaEndMinute: 20,
        permissibleEndHour: 16, permissibleEndMinute: 55,
        endHour: 17, endMinute: 20, icon: Icons.wb_sunny_outlined),
    PrayerData(id: 'maghrib', startHour: 17, startMinute: 28,
        fadilaEndHour: 17, fadilaEndMinute: 50,
        permissibleEndHour: 18, permissibleEndMinute: 15,
        endHour: 18, endMinute: 40, icon: Icons.wb_twilight_outlined),
    PrayerData(id: 'isha', startHour: 18, startMinute: 45,
        fadilaEndHour: 19, fadilaEndMinute: 45,
        permissibleEndHour: 21, permissibleEndMinute: 0,
        endHour: 23, endMinute: 59, icon: Icons.dark_mode_outlined),
  ];

  static const int sunriseHour = 6;
  static const int sunriseMinute = 45;
  static String get sunriseFormatted =>
      '${sunriseHour.toString().padLeft(2, '0')}:${sunriseMinute.toString().padLeft(2, '0')}';

  static int getActivePrayerIndex(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (int i = 0; i < todayPrayers.length; i++) {
      final p = todayPrayers[i];
      final start = p.startHour * 60 + p.startMinute;
      final end = p.endHour * 60 + p.endMinute;
      if (nowMin >= start && nowMin < end) return i;
    }
    return -1;
  }

  static double getProgress(int index, DateTime now) {
    if (index < 0) return 0.0;
    final p = todayPrayers[index];
    final startMin = p.startHour * 60 + p.startMinute;
    final endMin = p.endHour * 60 + p.endMinute;
    final nowMin = now.hour * 60 + now.minute + now.second / 60.0;
    return ((nowMin - startMin) / (endMin - startMin)).clamp(0.0, 1.0);
  }

  static PrayerZone getCurrentZone(int index, DateTime now) {
    if (index < 0) return PrayerZone.expired;
    final p = todayPrayers[index];
    final nowMin = now.hour * 60 + now.minute;
    if (nowMin < p.fadilaEndHour * 60 + p.fadilaEndMinute) return PrayerZone.fadila;
    if (nowMin < p.permissibleEndHour * 60 + p.permissibleEndMinute) return PrayerZone.permissible;
    if (nowMin < p.endHour * 60 + p.endMinute) return PrayerZone.makruh;
    return PrayerZone.expired;
  }

  static Color getZoneColor(PrayerZone zone) {
    switch (zone) {
      case PrayerZone.fadila: return AppColors.fadila;
      case PrayerZone.permissible: return AppColors.permissible;
      case PrayerZone.makruh: return AppColors.makruh;
      case PrayerZone.expired: return AppColors.missed;
    }
  }

  static String getZoneName(PrayerZone zone) {
    switch (zone) {
      case PrayerZone.fadila: return 'Фадиля';
      case PrayerZone.permissible: return 'Допустимо';
      case PrayerZone.makruh: return 'Макрух';
      case PrayerZone.expired: return 'Упущен';
    }
  }

  static String getTimeRemaining(int index, DateTime now) {
    if (index < 0) return '--:--';
    final p = todayPrayers[index];
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
    final p = todayPrayers[prayerIndex];
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
    for (var p in todayPrayers) {
      final start = p.startHour * 60 + p.startMinute;
      if (nowMin < start) return p.startTimeFormatted;
    }
    return todayPrayers.first.startTimeFormatted;
  }
}