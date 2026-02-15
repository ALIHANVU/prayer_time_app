import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/app_preferences.dart';
import 'core/services/notification_service.dart';
import 'app/app.dart';

void main() async {
  // Гарантируем что Flutter полностью инициализирован
  WidgetsFlutterBinding.ensureInitialized();

  // Делаем статус-бар прозрачным (красиво смотрится)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Загружаем сохранённые настройки (город, язык, метод и тд)
  await AppPreferences.init();

  // Инициализируем уведомления
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('⚠️ Ошибка инициализации уведомлений: $e');
  }

  // Запускаем приложение
  runApp(const PrayerApp());
}