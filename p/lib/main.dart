import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/app_preferences.dart';
import 'core/services/notification_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Прозрачный статус-бар
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Загружаем настройки и уведомления параллельно
  await AppPreferences.init();

  // Уведомления инициализируем не блокируя запуск приложения
  NotificationService.init().catchError((e) {
    debugPrint('⚠️ Ошибка инициализации уведомлений: $e');
  });

  runApp(const PrayerApp());
}