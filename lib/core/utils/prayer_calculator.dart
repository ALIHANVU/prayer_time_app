import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/prayer_api_service.dart';

// ╔══════════════════════════════════════════════════════════════════╗
// ║                КАЛЬКУЛЯТОР ВРЕМЕНИ НАМАЗА                       ║
// ║                                                                  ║
// ║  Все расчёты основаны на хадисах и мнениях учёных-салафов:      ║
// ║                                                                  ║
// ║  ДАЛИЛИ (ДОКАЗАТЕЛЬСТВА):                                       ║
// ║                                                                  ║
// ║  1. Хадис Абдуллаха ибн Амра ибн аль-Ас (Муслим):             ║
// ║     «Время Фаджра — пока не покажется край солнца.              ║
// ║      Время Зухра — когда солнце склонится, и тень              ║
// ║      человека станет равной его росту, до Аср.                   ║
// ║      Время Аср — пока солнце не пожелтеет.                      ║
// ║      Время Магриб — пока не исчезнет заря.                      ║
// ║      Время Иша — до середины ночи.»                             ║
// ║                                                                  ║
// ║  2. Хадис Укбы ибн Амира (Муслим 831) — ЗАПРЕТНЫЕ ВРЕМЕНА:    ║
// ║     «Три времени Посланник Аллаха ﷺ запретил нам молиться:     ║
// ║      a) Когда солнце восходит — пока не поднимется              ║
// ║      b) Когда солнце в зените — пока не пройдёт                 ║
// ║      c) Когда солнце начинает садиться — пока не сядет»         ║
// ║                                                                  ║
// ║  3. Ибн Усеймин (рахимахуЛлах):                                ║
// ║     - Середина ночи = середина от заката до рассвета            ║
// ║     - Время Иша заканчивается в середину ночи                   ║
// ║     - Красная заря на горизонте = конец Магриба                 ║
// ║                                                                  ║
// ║  4. Ибн Баз (рахимахуЛлах):                                    ║
// ║     - Аср: лучше молиться в начале его времени                  ║
// ║     - Пожелтение солнца = начало времени крайней нужды          ║
// ║                                                                  ║
// ║  ЗОНЫ ВРЕМЕНИ:                                                   ║
// ║                                                                  ║
// ║  🟢 ФАДИЛЯ (Лучшее время) — первая часть намаза                ║
// ║     Хадис: «Лучший намаз — намаз в начале его времени»          ║
// ║     (Абу Дауд, Тирмизи — хасан)                                ║
// ║                                                                  ║
// ║  🟡 ДОПУСТИМО (Джаваз) — средняя часть                         ║
// ║     Намаз действителен, но откладывать не стоит                  ║
// ║                                                                  ║
// ║  🔴 МАКРУХ (Нежелательно) — конец времени                       ║
// ║     Крайне нежелательно откладывать до этого времени             ║
// ║                                                                  ║
// ║  ОСОБЕННОСТИ РАСЧЁТА ДЛЯ КАЖДОГО НАМАЗА:                       ║
// ║                                                                  ║
// ║  ФАДЖР: Фадиля = первые 35% (хадис Аиши — «сура 60-100       ║
// ║         аятов», т.е. первые минуты). Конец = восход.            ║
// ║                                                                  ║
// ║  ЗУХР:  Фадиля = первая 1/3. Конец = начало Аср.               ║
// ║         Зимой лучше раньше, летом можно чуть позже.             ║
// ║                                                                  ║
// ║  АСР:   Фадиля = первые 35%. Макрух начинается при             ║
// ║         пожелтении солнца (~40 мин до заката).                  ║
// ║         Конец = 15 мин до заката (начало запретного).           ║
// ║                                                                  ║
// ║  МАГРИБ: КОРОТКОЕ время! Фадиля = первые 15-20 мин.            ║
// ║          Сунна — молиться СРАЗУ после заката.                   ║
// ║          Конец = начало Иша (исчезновение красной зари).        ║
// ║                                                                  ║
// ║  ИША:   Фадиля = первая 1/3. Конец = середина ночи             ║
// ║         (по мнению Ибн Усеймина).                               ║
// ╚══════════════════════════════════════════════════════════════════╝

enum PrayerStatus { completed, active, upcoming }

enum PrayerZone { fadila, permissible, makruh, expired }

/// Данные о запретном времени
class ForbiddenTime {
  final String id;
  final String nameRu;
  final String nameEn;
  final String descRu;
  final String descEn;
  final String dalil;
  final int startMin;
  final int endMin;

  const ForbiddenTime({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.descRu,
    required this.descEn,
    required this.dalil,
    required this.startMin,
    required this.endMin,
  });

  String get startFormatted => _fmt(startMin);
  String get endFormatted => _fmt(endMin);

  bool isActiveAt(int nowMin) => nowMin >= startMin && nowMin < endMin;
  bool isUpcomingIn(int nowMin, int withinMinutes) =>
      nowMin < startMin && (startMin - nowMin) <= withinMinutes;

  static String _fmt(int totalMin) {
    final h = (totalMin ~/ 60) % 24;
    final m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

/// Данные о намазе с зонами
class PrayerData {
  final String id;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  // Границы зон (в минутах от полуночи)
  final int fadilaEndMin;
  final int permissibleEndMin;

  final IconData icon;

  const PrayerData({
    required this.id,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.fadilaEndMin,
    required this.permissibleEndMin,
    required this.icon,
  });

  int get startMin => startHour * 60 + startMinute;
  int get endMin => endHour * 60 + endMinute;

  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  int get totalMinutes {
    int total = endMin - startMin;
    if (total < 0) total += 24 * 60; // после полуночи (Иша)
    return total;
  }

  String get durationText {
    final total = totalMinutes;
    if (total <= 0) return '--';
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0) return '${h}ч ${m}м';
    return '${m}м';
  }

  double get fadilaFraction {
    final fadilaDur = fadilaEndMin - startMin;
    return fadilaDur / totalMinutes;
  }

  double get permissibleFraction {
    final permDur = permissibleEndMin - fadilaEndMin;
    return permDur / totalMinutes;
  }

  double get makruhFraction => 1.0 - fadilaFraction - permissibleFraction;
}

class PrayerCalculator {
  // ═══════════════════════════════════════
  // Текущие данные (обновляются из API)
  // ═══════════════════════════════════════

  static List<PrayerData> _prayers = [];
  static List<ForbiddenTime> _forbiddenTimes = [];
  static int _sunriseMin = 0;
  static int _midnightMin = 0;
  static String _hijriDate = '';

  static List<PrayerData> get todayPrayers => _prayers;
  static List<ForbiddenTime> get forbiddenTimes => _forbiddenTimes;
  static int get sunriseMinutes => _sunriseMin;
  static String get hijriDate => _hijriDate;

  // ═══════════════════════════════════════
  // ОБНОВЛЕНИЕ ИЗ API
  // ═══════════════════════════════════════

  static void updateFromApi(DayPrayerTimes apiData) {
    final fajr = apiData.fajr;
    final sunrise = apiData.sunrise;
    final dhuhr = apiData.dhuhr;
    final asr = apiData.asr;
    final maghrib = apiData.maghrib;
    final isha = apiData.isha;

    _sunriseMin = sunrise.hour * 60 + sunrise.minute;

    final fajrMin = fajr.hour * 60 + fajr.minute;
    final dhuhrMin = dhuhr.hour * 60 + dhuhr.minute;
    final asrMin = asr.hour * 60 + asr.minute;
    final maghribMin = maghrib.hour * 60 + maghrib.minute;
    final ishaMin = isha.hour * 60 + isha.minute;

    // ═══ Середина ночи ═══
    // Ибн Усеймин: от заката до рассвета / 2
    final nextFajr = fajrMin + 24 * 60;
    _midnightMin = (maghribMin + (nextFajr - maghribMin) ~/ 2);

    // ═══ Конец каждого намаза ═══
    final fajrEnd = _sunriseMin;
    final dhuhrEnd = asrMin;
    final asrEnd = maghribMin - 15; // 15 мин до заката — запретное время
    final maghribEnd = ishaMin;
    final ishaEnd = _midnightMin > 24 * 60
        ? _midnightMin - 24 * 60
        : _midnightMin;

    // ═══ РАСЧЁТ ЗОН ═══

    // ФАДЖР: фадиля ~35%, допустимо ~35%, макрух ~30%
    final fajrTotal = fajrEnd - fajrMin;
    final fajrFadilaEnd = fajrMin + (fajrTotal * 0.35).round();
    final fajrPermEnd = fajrMin + (fajrTotal * 0.70).round();

    // ЗУХР: фадиля ~33%, допустимо ~34%, макрух ~33%
    final dhuhrTotal = dhuhrEnd - dhuhrMin;
    final dhuhrFadilaEnd = dhuhrMin + (dhuhrTotal * 0.33).round();
    final dhuhrPermEnd = dhuhrMin + (dhuhrTotal * 0.67).round();

    // АСР: фадиля ~35%, допустимо до пожелтения, макрух = пожелтение
    final asrTotal = asrEnd - asrMin;
    final yellowTime = maghribMin - 40; // пожелтение ~40 мин до заката
    final asrFadilaEnd = asrMin + (asrTotal * 0.35).round();
    int asrPermEnd = yellowTime;
    if (asrPermEnd <= asrFadilaEnd) {
      asrPermEnd = asrMin + (asrTotal * 0.65).round();
    }

    // МАГРИБ: короткое время! Фадиля = первые 15-20 мин
    final maghribTotal = maghribEnd - maghribMin;
    final maghribFadilaEnd = maghribMin + (maghribTotal * 0.25).round().clamp(0, 20);
    final maghribPermEnd = maghribMin + (maghribTotal * 0.60).round();

    // ИША: фадиля ~33%, допустимо ~34%, макрух ~33%
    int ishaTotal;
    if (ishaEnd > ishaMin) {
      ishaTotal = ishaEnd - ishaMin;
    } else {
      ishaTotal = (24 * 60 - ishaMin) + ishaEnd;
    }
    final ishaFadilaEnd = ishaMin + (ishaTotal * 0.33).round();
    final ishaPermEnd = ishaMin + (ishaTotal * 0.67).round();

    _prayers = [
      PrayerData(
        id: 'fajr',
        startHour: fajr.hour, startMinute: fajr.minute,
        endHour: sunrise.hour, endMinute: sunrise.minute,
        fadilaEndMin: fajrFadilaEnd,
        permissibleEndMin: fajrPermEnd,
        icon: Icons.nights_stay_outlined,
      ),
      PrayerData(
        id: 'dhuhr',
        startHour: dhuhr.hour, startMinute: dhuhr.minute,
        endHour: asr.hour, endMinute: asr.minute,
        fadilaEndMin: dhuhrFadilaEnd,
        permissibleEndMin: dhuhrPermEnd,
        icon: Icons.light_mode_outlined,
      ),
      PrayerData(
        id: 'asr',
        startHour: asr.hour, startMinute: asr.minute,
        endHour: asrEnd ~/ 60, endMinute: asrEnd % 60,
        fadilaEndMin: asrFadilaEnd,
        permissibleEndMin: asrPermEnd,
        icon: Icons.wb_sunny_outlined,
      ),
      PrayerData(
        id: 'maghrib',
        startHour: maghrib.hour, startMinute: maghrib.minute,
        endHour: isha.hour, endMinute: isha.minute,
        fadilaEndMin: maghribFadilaEnd,
        permissibleEndMin: maghribPermEnd,
        icon: Icons.wb_twilight_outlined,
      ),
      PrayerData(
        id: 'isha',
        startHour: isha.hour, startMinute: isha.minute,
        endHour: ishaEnd ~/ 60, endMinute: ishaEnd % 60,
        fadilaEndMin: ishaFadilaEnd % (24 * 60),
        permissibleEndMin: ishaPermEnd % (24 * 60),
        icon: Icons.dark_mode_outlined,
      ),
    ];

    // ═══ ЗАПРЕТНЫЕ ВРЕМЕНА ═══
    _forbiddenTimes = [
      ForbiddenTime(
        id: 'sunrise',
        nameRu: 'Восход (шурук)',
        nameEn: 'Sunrise (Shuruq)',
        descRu: 'Запрещено молиться от восхода до подъёма солнца на высоту копья',
        descEn: 'Prayer is prohibited from sunrise until the sun rises to the height of a spear',
        dalil: 'Хадис Укбы ибн Амира (Муслим 831)',
        startMin: _sunriseMin,
        endMin: _sunriseMin + 15,
      ),
      ForbiddenTime(
        id: 'zenith',
        nameRu: 'Зенит (завваль)',
        nameEn: 'Zenith (Zawal)',
        descRu: 'Запрещено молиться когда солнце точно в зените',
        descEn: 'Prayer is prohibited when the sun is at its zenith',
        dalil: 'Хадис Укбы ибн Амира (Муслим 831)',
        startMin: dhuhrMin - 5,
        endMin: dhuhrMin,
      ),
      ForbiddenTime(
        id: 'sunset',
        nameRu: 'Закат',
        nameEn: 'Sunset',
        descRu: 'Запрещено молиться когда солнце начинает садиться (кроме текущего Аср)',
        descEn: 'Prayer is prohibited when the sun starts to set (except current Asr)',
        dalil: 'Хадис Укбы ибн Амира (Муслим 831)',
        startMin: maghribMin - 15,
        endMin: maghribMin,
      ),
    ];

    // Хиджра
    if (apiData.hijriDate.isNotEmpty) {
      _hijriDate = '${apiData.hijriDate}${apiData.hijriMonth ?? ''} ${apiData.hijriYear ?? ''}';
    }
  }

  // ═══════════════════════════════════════
  // ОПРЕДЕЛЕНИЕ ТЕКУЩЕГО НАМАЗА
  // ═══════════════════════════════════════

  static int getActivePrayerIndex(DateTime now) {
    if (_prayers.isEmpty) return -1;
    final nowMin = now.hour * 60 + now.minute + now.second / 60.0;

    for (int i = 0; i < _prayers.length; i++) {
      final p = _prayers[i];
      double end = p.endMin.toDouble();

      // Иша может заканчиваться после полуночи
      if (p.id == 'isha' && end < p.startMin) end += 24 * 60;

      double checkNow = nowMin;
      if (p.id == 'isha' && nowMin < p.startMin && nowMin < 12 * 60) {
        checkNow += 24 * 60;
      }

      if (checkNow >= p.startMin && checkNow < end) return i;
    }

    return -1;
  }

  // ═══════════════════════════════════════
  // ТЕКУЩАЯ ЗОНА
  // ═══════════════════════════════════════

  static PrayerZone getCurrentZone(int index, DateTime now) {
    if (index < 0 || index >= _prayers.length) return PrayerZone.expired;

    final p = _prayers[index];
    final nowMin = now.hour * 60 + now.minute;

    if (nowMin >= p.permissibleEndMin) return PrayerZone.makruh;
    if (nowMin >= p.fadilaEndMin) return PrayerZone.permissible;
    return PrayerZone.fadila;
  }

  // ═══════════════════════════════════════
  // ПРОГРЕСС (0.0 — 1.0)
  // ═══════════════════════════════════════

  static double getProgress(int index, DateTime now) {
    if (index < 0 || index >= _prayers.length) return 0;

    final p = _prayers[index];
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    final startSec = p.startMin * 60;
    int endSec = p.endMin * 60;

    if (p.id == 'isha' && endSec < startSec) endSec += 24 * 3600;

    final progress = (nowSec - startSec) / (endSec - startSec);
    return progress.clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════
  // ЦВЕТ ЗОНЫ
  // ═══════════════════════════════════════

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

  // ═══════════════════════════════════════
  // ОСТАВШЕЕСЯ ВРЕМЯ
  // ═══════════════════════════════════════

  static String getTimeRemaining(int index, DateTime now) {
    if (index < 0 || index >= _prayers.length) return '--:--';

    final p = _prayers[index];
    final endSec = p.endMin * 60;
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;

    int rem = endSec - nowSec;
    if (p.id == 'isha' && rem < 0) rem += 24 * 3600;

    if (rem <= 0) return '0:00';
    final h = rem ~/ 3600;
    final m = (rem % 3600) ~/ 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}';
    return '0:${m.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════
  // СТАТУС НАМАЗА
  // ═══════════════════════════════════════

  static PrayerStatus getStatus(int prayerIndex, int activeIndex, DateTime now) {
    if (activeIndex >= 0) {
      if (prayerIndex < activeIndex) return PrayerStatus.completed;
      if (prayerIndex == activeIndex) return PrayerStatus.active;
      return PrayerStatus.upcoming;
    }

    final nowMin = now.hour * 60 + now.minute;
    final p = _prayers[prayerIndex];
    return nowMin >= p.endMin ? PrayerStatus.completed : PrayerStatus.upcoming;
  }

  // ═══════════════════════════════════════
  // АКТИВНОЕ ЗАПРЕТНОЕ ВРЕМЯ
  // ═══════════════════════════════════════

  static ForbiddenTime? getActiveForbiddenTime(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final f in _forbiddenTimes) {
      if (f.isActiveAt(nowMin)) return f;
    }
    return null;
  }

  /// Ближайшее запретное время (в пределах 30 мин)
  static ForbiddenTime? getUpcomingForbiddenTime(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final f in _forbiddenTimes) {
      if (f.isUpcomingIn(nowMin, 30)) return f;
    }
    return null;
  }

  // ═══════════════════════════════════════
  // ВРЕМЯ ДО СЛЕДУЮЩЕГО НАМАЗА (из промежутка)
  // ═══════════════════════════════════════

  static String getNextPrayerName(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final p in _prayers) {
      if (nowMin < p.startMin) return p.id;
    }
    return _prayers.first.id;
  }

  static String getNextPrayerTime(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final p in _prayers) {
      if (nowMin < p.startMin) return p.startTimeFormatted;
    }
    return _prayers.first.startTimeFormatted;
  }
}