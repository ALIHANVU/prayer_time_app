import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'languages/ru.dart';
import 'languages/en.dart';
import 'languages/ar.dart';
import 'languages/ce.dart';

// Реэкспорт чтобы другие файлы могли импортировать AppStrings отсюда
export 'app_strings.dart';

class AppLocalizations extends InheritedWidget {
  final AppStrings strings;
  final Locale locale;

  const AppLocalizations({
    super.key,
    required this.strings,
    required this.locale,
    required super.child,
  });

  /// Получить строки из контекста (внутри виджетов)
  static AppStrings of(BuildContext context) {
    final widget =
    context.dependOnInheritedWidgetOfExactType<AppLocalizations>();
    return widget?.strings ?? ruStrings;
  }

  /// Получить строки по коду языка (без контекста)
  static AppStrings getStrings(String langCode) {
    switch (langCode) {
      case 'ru':
        return ruStrings;
      case 'en':
        return enStrings;
      case 'ar':
        return arStrings;
      case 'ce':
        return ceStrings;
      default:
        return ruStrings;
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('ar'),
    Locale('ce'),
  ];

  static const Map<String, String> languageNames = {
    'ru': 'Русский',
    'en': 'English',
    'ar': 'العربية',
    'ce': 'Нохчийн',
  };

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) =>
      locale != oldWidget.locale;
}