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

  static int _nextId = 0;

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> scheduleAllPrayers({int minutesBefore = 15}) async {
    await _plugin.cancelAll();
    _nextId = 0;

    if (!AppPreferences.notificationsEnabled) return;

    final prayers = PrayerCalculator.todayPrayers;
    if (prayers.isEmpty) return;

    final now = DateTime.now();
    final strings = AppLocalizations.getStrings(AppPreferences.language);

    // ═══ 1. Намазы ═══
    await _schedulePrayerNotifications(prayers, now, strings, minutesBefore);

    // ═══ 2. Запретные времена ═══
    if (AppPreferences.notifyForbiddenTimes) {
      await _scheduleForbiddenNotifications(now, strings);
    }

    // ═══ 3. Духа ═══
    if (AppPreferences.notifyDuha) {
      await _scheduleDuhaNotification(now, strings);
    }

    // ═══ 4. Тахаджуд ═══
    if (AppPreferences.notifyTahajjud) {
      await _scheduleTahajjudNotification(prayers, now, strings);
    }

    debugPrint('Scheduled $_nextId notifications');
  }

  /// Планируем уведомления для каждого намаза
  static Future<void> _schedulePrayerNotifications(
      List<PrayerData> prayers,
      DateTime now,
      AppStrings strings,
      int minutesBefore,
      ) async {
    for (final prayer in prayers) {
      if (!AppPreferences.isPrayerEnabled(prayer.id)) continue;

      final name = strings.prayerName(prayer.id);
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        prayer.startHour, prayer.startMinute,
      );

      // В момент начала
      if (AppPreferences.notifyAtPrayerTime && prayerTime.isAfter(now)) {
        await _scheduleOne(
          title: '$name — ${strings.notificationPrayerTime}',
          body: '${strings.notificationPrayerStarted} $name (${prayer.startTimeFormatted})',
          dateTime: prayerTime,
          channel: 'prayer_start',
          channelName: strings.notificationPrayerTime,
        );
      }

      // За N минут
      if (AppPreferences.notifyBeforePrayer && minutesBefore > 0) {
        final reminderTime =
        prayerTime.subtract(Duration(minutes: minutesBefore));
        if (reminderTime.isAfter(now)) {
          await _scheduleOne(
            title:
            '${strings.notificationReminder} $minutesBefore ${strings.minutes} — $name',
            body:
            '$name ${strings.notificationReminderBody} ${prayer.startTimeFormatted}',
            dateTime: reminderTime,
            channel: 'prayer_reminder',
            channelName: strings.notificationReminder,
          );
        }
      }

      // Макрух — намаз скоро закончится
      if (AppPreferences.notifyMakruhWarning) {
        final makruhMin = prayer.permissibleEndMin;
        final makruhTime = DateTime(
          now.year, now.month, now.day,
          makruhMin ~/ 60, makruhMin % 60,
        );
        if (makruhTime.isAfter(now)) {
          await _scheduleOne(
            title: '⚠️ $name — ${strings.zoneMakruh}',
            body: strings.notifyMakruhBody,
            dateTime: makruhTime,
            channel: 'prayer_makruh',
            channelName: strings.zoneMakruh,
          );
        }
      }
    }
  }

  /// Планируем уведомления о запретных временах
  static Future<void> _scheduleForbiddenNotifications(
      DateTime now,
      AppStrings strings,
      ) async {
    for (final f in PrayerCalculator.forbiddenTimes) {
      final fTime = DateTime(
        now.year, now.month, now.day,
        f.startMin ~/ 60, f.startMin % 60,
      );
      final warnTime = fTime.subtract(const Duration(minutes: 5));
      if (warnTime.isAfter(now)) {
        final fName = _forbiddenName(f.id, strings);
        await _scheduleOne(
          title: '⛔ ${strings.forbiddenSoonTitle}',
          body: '$fName — ${strings.forbiddenIn} 5 ${strings.minutes}',
          dateTime: warnTime,
          channel: 'forbidden_times',
          channelName: strings.forbiddenActive,
        );
      }
    }
  }

  /// Имя запретного времени по ID
  static String _forbiddenName(String id, AppStrings strings) {
    switch (id) {
      case 'sunrise': return strings.forbiddenSunriseName;
      case 'zenith': return strings.forbiddenZenithName;
      case 'sunset': return strings.forbiddenSunsetName;
      default: return id;
    }
  }

  /// Уведомление о намазе Духа
  static Future<void> _scheduleDuhaNotification(
      DateTime now,
      AppStrings strings,
      ) async {
    final duhaStartMin = PrayerCalculator.sunriseMinutes + 15;
    final duhaTime = DateTime(
      now.year, now.month, now.day,
      duhaStartMin ~/ 60, duhaStartMin % 60,
    );
    if (duhaTime.isAfter(now)) {
      await _scheduleOne(
        title: '🌞 ${strings.duha}',
        body: strings.notifyDuhaBody,
        dateTime: duhaTime,
        channel: 'optional_prayers',
        channelName: strings.duha,
      );
    }
  }

  /// Уведомление о Тахаджуде
  static Future<void> _scheduleTahajjudNotification(
      List<PrayerData> prayers,
      DateTime now,
      AppStrings strings,
      ) async {
    final fajr = prayers.firstWhere((p) => p.id == 'fajr');
    final fajrTime = DateTime(
      now.year, now.month, now.day,
      fajr.startHour, fajr.startMinute,
    );
    final tahajjudTime = fajrTime.subtract(const Duration(minutes: 90));
    if (tahajjudTime.isAfter(now)) {
      await _scheduleOne(
        title: '🌙 ${strings.tahajjud}',
        body: strings.notifyTahajjudBody,
        dateTime: tahajjudTime,
        channel: 'optional_prayers',
        channelName: strings.tahajjud,
      );
    }
  }

  static Future<void> _scheduleOne({
    required String title,
    required String body,
    required DateTime dateTime,
    required String channel,
    required String channelName,
  }) async {
    final id = _nextId++;
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
    final androidDetails = AndroidNotificationDetails(
      channel,
      channelName,
      channelDescription: channelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      id, title, body, tzDateTime, details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> showTestNotification() async {
    final strings = AppLocalizations.getStrings(AppPreferences.language);
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'Prayer Times',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      999,
      strings.notificationTest,
      strings.notificationTestBody,
      details,
    );
  }
}