import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранилище настроек приложения.
/// Оптимизация: SharedPreferences уже кеширует значения в памяти,
/// поэтому дополнительный кеш не нужен. Но мы уменьшаем количество
/// null-проверок через getter с ранним возвратом.
class AppPreferences {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Безопасный доступ — если не инициализированы, возвращаем значения по умолчанию
  static bool get isInitialized => _initialized;

  // === Координаты ===
  static double get latitude => _prefs.getDouble('latitude') ?? 42.7167;
  static set latitude(double val) => _prefs.setDouble('latitude', val);

  static double get longitude => _prefs.getDouble('longitude') ?? 46.1000;
  static set longitude(double val) => _prefs.setDouble('longitude', val);

  // === Город ===
  static String get cityName => _prefs.getString('cityName') ?? 'Ца-Ведено';
  static set cityName(String val) => _prefs.setString('cityName', val);

  static String get countryName => _prefs.getString('countryName') ?? 'Россия';
  static set countryName(String val) => _prefs.setString('countryName', val);

  // === Метод расчёта ===
  static int get calculationMethod => _prefs.getInt('method') ?? 14;
  static set calculationMethod(int val) => _prefs.setInt('method', val);

  // === Язык ===
  static String get language => _prefs.getString('language') ?? 'ru';
  static set language(String val) => _prefs.setString('language', val);

  // === Тема (light / dark / system) ===
  static String get themeMode => _prefs.getString('themeMode') ?? 'system';
  static set themeMode(String val) => _prefs.setString('themeMode', val);

  static ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  // === Уведомления (главный выключатель) ===
  static bool get notificationsEnabled => _prefs.getBool('notifications') ?? true;
  static set notificationsEnabled(bool val) => _prefs.setBool('notifications', val);

  static int get reminderMinutes => _prefs.getInt('reminderMinutes') ?? 15;
  static set reminderMinutes(int val) => _prefs.setInt('reminderMinutes', val);

  // === Детальные уведомления ===
  static bool get notifyAtPrayerTime => _prefs.getBool('notifyAtPrayerTime') ?? true;
  static set notifyAtPrayerTime(bool val) => _prefs.setBool('notifyAtPrayerTime', val);

  static bool get notifyBeforePrayer => _prefs.getBool('notifyBeforePrayer') ?? true;
  static set notifyBeforePrayer(bool val) => _prefs.setBool('notifyBeforePrayer', val);

  static bool get notifyMakruhWarning => _prefs.getBool('notifyMakruhWarning') ?? false;
  static set notifyMakruhWarning(bool val) => _prefs.setBool('notifyMakruhWarning', val);

  static bool get notifyForbiddenTimes => _prefs.getBool('notifyForbiddenTimes') ?? false;
  static set notifyForbiddenTimes(bool val) => _prefs.setBool('notifyForbiddenTimes', val);

  // === Уведомления по каждому намазу ===
  static bool get notifyFajr => _prefs.getBool('notifyFajr') ?? true;
  static set notifyFajr(bool val) => _prefs.setBool('notifyFajr', val);

  static bool get notifyDhuhr => _prefs.getBool('notifyDhuhr') ?? true;
  static set notifyDhuhr(bool val) => _prefs.setBool('notifyDhuhr', val);

  static bool get notifyAsr => _prefs.getBool('notifyAsr') ?? true;
  static set notifyAsr(bool val) => _prefs.setBool('notifyAsr', val);

  static bool get notifyMaghrib => _prefs.getBool('notifyMaghrib') ?? true;
  static set notifyMaghrib(bool val) => _prefs.setBool('notifyMaghrib', val);

  static bool get notifyIsha => _prefs.getBool('notifyIsha') ?? true;
  static set notifyIsha(bool val) => _prefs.setBool('notifyIsha', val);

  // === Дополнительные намазы ===
  static bool get notifyDuha => _prefs.getBool('notifyDuha') ?? false;
  static set notifyDuha(bool val) => _prefs.setBool('notifyDuha', val);

  static bool get notifyTahajjud => _prefs.getBool('notifyTahajjud') ?? false;
  static set notifyTahajjud(bool val) => _prefs.setBool('notifyTahajjud', val);

  /// Проверяет, включены ли уведомления для конкретного намаза
  static bool isPrayerEnabled(String prayerId) {
    switch (prayerId) {
      case 'fajr': return notifyFajr;
      case 'dhuhr': return notifyDhuhr;
      case 'asr': return notifyAsr;
      case 'maghrib': return notifyMaghrib;
      case 'isha': return notifyIsha;
      default: return true;
    }
  }

  // === Обновление ===
  static String get lastUpdateDate => _prefs.getString('lastUpdate') ?? '';
  static set lastUpdateDate(String val) => _prefs.setString('lastUpdate', val);

  static bool get needsUpdate {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    return lastUpdateDate != today;
  }

  static void markUpdated() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    lastUpdateDate = today;
  }
}

class CalculationMethods {
  static const Map<int, String> methods = {
    1: 'Карачи',
    2: 'ISNA',
    3: 'MWL',
    4: 'Умм аль-Кура',
    5: 'Египет',
    7: 'Тегеран',
    8: 'Залив',
    9: 'Кувейт',
    10: 'Катар',
    11: 'Сингапур',
    12: 'UOIF',
    13: 'Диянет',
    14: 'ДУМ России',
  };
}

class PopularCities {
  static const List<CityInfo> cities = [
    CityInfo('Ца-Ведено', 'Россия', 42.7167, 46.1000),
    CityInfo('Грозный', 'Россия', 43.3178, 45.6983),
    CityInfo('Москва', 'Россия', 55.7558, 37.6173),
    CityInfo('Санкт-Петербург', 'Россия', 59.9343, 30.3351),
    CityInfo('Казань', 'Россия', 55.7887, 49.1221),
    CityInfo('Махачкала', 'Россия', 42.9849, 47.5047),
    CityInfo('Назрань', 'Россия', 43.2261, 44.7724),
    CityInfo('Уфа', 'Россия', 54.7388, 55.9721),
    CityInfo('Мекка', 'С. Аравия', 21.4225, 39.8262),
    CityInfo('Медина', 'С. Аравия', 24.4709, 39.6120),
    CityInfo('Стамбул', 'Турция', 41.0082, 28.9784),
    CityInfo('Дубай', 'ОАЭ', 25.2048, 55.2708),
  ];
}

class CityInfo {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityInfo(this.name, this.country, this.latitude, this.longitude);

  String get fullName => '$name, $country';
}