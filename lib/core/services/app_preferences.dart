import 'package:shared_preferences/shared_preferences.dart';

/// Хранилище настроек приложения.
/// Сохраняет город, координаты, язык, метод расчёта и настройки уведомлений.
class AppPreferences {
  static SharedPreferences? _prefs;

  /// Инициализация (вызвать в main.dart один раз)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // === Координаты города ===

  static double get latitude => _prefs?.getDouble('latitude') ?? 42.7167;
  static set latitude(double val) => _prefs?.setDouble('latitude', val);

  static double get longitude => _prefs?.getDouble('longitude') ?? 46.1000;
  static set longitude(double val) => _prefs?.setDouble('longitude', val);

  // === Название города ===

  static String get cityName => _prefs?.getString('cityName') ?? 'Ца-Ведено';
  static set cityName(String val) => _prefs?.setString('cityName', val);

  static String get countryName =>
      _prefs?.getString('countryName') ?? 'Россия';
  static set countryName(String val) => _prefs?.setString('countryName', val);

  // === Метод расчёта ===

  static int get calculationMethod => _prefs?.getInt('method') ?? 14;
  static set calculationMethod(int val) => _prefs?.setInt('method', val);

  // === Язык ===

  static String get language => _prefs?.getString('language') ?? 'ru';
  static set language(String val) => _prefs?.setString('language', val);

  // === Уведомления ===

  static bool get notificationsEnabled =>
      _prefs?.getBool('notifications') ?? true;
  static set notificationsEnabled(bool val) =>
      _prefs?.setBool('notifications', val);

  /// За сколько минут до намаза напоминать
  static int get reminderMinutes =>
      _prefs?.getInt('reminderMinutes') ?? 15;
  static set reminderMinutes(int val) =>
      _prefs?.setInt('reminderMinutes', val);

  // === Последнее обновление данных ===

  static String get lastUpdateDate =>
      _prefs?.getString('lastUpdate') ?? '';
  static set lastUpdateDate(String val) =>
      _prefs?.setString('lastUpdate', val);

  /// Нужно ли обновить данные (обновляем раз в день)
  static bool get needsUpdate {
    final today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    return lastUpdateDate != today;
  }

  /// Отметить, что данные обновлены
  static void markUpdated() {
    final today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    lastUpdateDate = today;
  }
}

/// Список доступных методов расчёта
class CalculationMethods {
  static const Map<int, String> methods = {
    1: 'Карачи',
    2: 'ISNA (Сев. Америка)',
    3: 'Мусульманская Всемирная Лига',
    4: 'Умм аль-Кура (Мекка)',
    5: 'Египет',
    7: 'Тегеран',
    8: 'Персидский залив',
    9: 'Кувейт',
    10: 'Катар',
    11: 'Сингапур',
    12: 'UOIF (Франция)',
    13: 'Диянет (Турция)',
    14: 'ДУМ России',
  };
}

/// Список популярных городов
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