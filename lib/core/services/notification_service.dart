import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/prayer_calculator.dart';
import '../l10n/app_localizations.dart';
import 'app_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('🔔 Нажали на уведомление: ${response.payload}');
      },
    );

    await _requestPermission();
    debugPrint('✅ Уведомления инициализированы');
  }

  static Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleAllPrayers({int minutesBefore = 15}) async {
    await _plugin.cancelAll();

    final prayers = PrayerCalculator.todayPrayers;
    final now = DateTime.now();

    // Берём переводы для текущего языка
    final strings = AppLocalizations.getStrings(AppPreferences.language);

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final name = strings.prayerName(prayer.id);

      final prayerTime = DateTime(
        now.year, now.month, now.day,
        prayer.startHour, prayer.startMinute,
      );

      // Уведомление В МОМЕНТ намаза
      if (prayerTime.isAfter(now)) {
        await _scheduleOne(
          id: i * 10,
          title: '${strings.notificationPrayerTime}: $name',
          body: '${strings.notificationPrayerStarted} $name (${prayer.startTimeFormatted})',
          dateTime: prayerTime,
        );
      }

      // Уведомление ЗА N МИНУТ
      if (minutesBefore > 0) {
        final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
        if (reminderTime.isAfter(now)) {
          await _scheduleOne(
            id: i * 10 + 1,
            title: '${strings.notificationReminder} $minutesBefore мин — $name',
            body: '$name ${strings.notificationReminderBody} ${prayer.startTimeFormatted}',
            dateTime: reminderTime,
          );
        }
      }
    }

    debugPrint('✅ Все уведомления запланированы');
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Время намаза',
      channelDescription: 'Уведомления о времени намаза',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      id, title, body, tzDateTime, details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> showTestNotification() async {
    final strings = AppLocalizations.getStrings(AppPreferences.language);

    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel', 'Время намаза',
      channelDescription: 'Уведомления о времени намаза',
      importance: Importance.high, priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(999, strings.notificationTest, strings.notificationTestBody, details);
  }
}