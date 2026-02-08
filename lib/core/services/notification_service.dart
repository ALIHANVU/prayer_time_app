import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/prayer_calculator.dart';
import 'app_preferences.dart';

/// Сервис уведомлений о намазах.
///
/// Что он делает:
/// - Показывает уведомление когда наступает время намаза
/// - Показывает уведомление за N минут ДО намаза (настраивается)
/// - Автоматически перепланирует на каждый день
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Названия намазов для уведомлений
  static const Map<String, String> _prayerNamesRu = {
    'fajr': 'Фаджр',
    'dhuhr': 'Зухр',
    'asr': 'Аср',
    'maghrib': 'Магриб',
    'isha': 'Иша',
  };

  /// Инициализация (вызвать один раз при запуске)
  static Future<void> init() async {
    // Инициализируем часовые пояса
    tz.initializeTimeZones();

    // Настройки для Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // Иконка приложения
    );

    // Общие настройки
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('🔔 Нажали на уведомление: ${response.payload}');
      },
    );

    // Запрашиваем разрешение на Android 13+
    await _requestPermission();

    debugPrint('✅ Уведомления инициализированы');
  }

  /// Запрос разрешения (Android 13+ требует явного разрешения)
  static Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  /// Запланировать уведомления для всех намазов на сегодня.
  ///
  /// [minutesBefore] — за сколько минут до намаза напоминать (0 = не напоминать заранее)
  static Future<void> scheduleAllPrayers({int minutesBefore = 15}) async {
    // Сначала отменяем все старые уведомления
    await _plugin.cancelAll();

    final prayers = PrayerCalculator.todayPrayers;
    final now = DateTime.now();

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final name = _prayerNamesRu[prayer.id] ?? prayer.id;

      // Время начала намаза
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        prayer.startHour, prayer.startMinute,
      );

      // --- Уведомление В МОМЕНТ намаза ---
      if (prayerTime.isAfter(now)) {
        await _scheduleOne(
          id: i * 10, // уникальный id: 0, 10, 20, 30, 40
          title: '🕌 Время намаза: $name',
          body: 'Наступило время намаза $name (${prayer.startTimeFormatted})',
          dateTime: prayerTime,
        );
        debugPrint('📅 Запланировано: $name в ${prayer.startTimeFormatted}');
      }

      // --- Уведомление ЗА N МИНУТ ---
      if (minutesBefore > 0) {
        final reminderTime = prayerTime.subtract(
          Duration(minutes: minutesBefore),
        );

        if (reminderTime.isAfter(now)) {
          await _scheduleOne(
            id: i * 10 + 1, // уникальный id: 1, 11, 21, 31, 41
            title: '⏰ Через $minutesBefore мин — $name',
            body: 'Намаз $name начнётся в ${prayer.startTimeFormatted}',
            dateTime: reminderTime,
          );
          debugPrint(
            '📅 Напоминание: $name за $minutesBefore мин',
          );
        }
      }
    }

    debugPrint('✅ Все уведомления запланированы');
  }

  /// Запланировать одно уведомление
  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    // Конвертируем в TZDateTime (с часовым поясом)
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel', // id канала
      'Время намаза', // имя канала (видно в настройках Android)
      channelDescription: 'Уведомления о времени намаза',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Добавляем обязательный параметр для iOS
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null, // Без повтора, планируем на конкретное время
    );
  }

  /// Отменить все уведомления
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('🔕 Все уведомления отменены');
  }

  /// Показать тестовое уведомление (для проверки)
  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Время намаза',
      channelDescription: 'Уведомления о времени намаза',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      999,
      '🕌 Тестовое уведомление',
      'Уведомления работают! Вы будете получать напоминания о намазах.',
      details,
    );
  }
}