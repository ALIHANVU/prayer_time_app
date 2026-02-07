import 'package:flutter/material.dart';

class AppStrings {
  final String appTitle;
  final String today;
  final String timeRemaining;
  final String completed;
  final String active;
  final String sunriseTitle;
  final String sunriseSubtitle;
  final String scheduleTitle;
  final String nextPrayer;
  final String home;
  final String qibla;
  final String profile;
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const AppStrings({
    required this.appTitle, required this.today, required this.timeRemaining,
    required this.completed, required this.active, required this.sunriseTitle,
    required this.sunriseSubtitle, required this.scheduleTitle,
    required this.nextPrayer, required this.home, required this.qibla,
    required this.profile, required this.fajr, required this.dhuhr,
    required this.asr, required this.maghrib, required this.isha,
  });
}

const ruStrings = AppStrings(
  appTitle: 'Время намаза', today: 'СЕГОДНЯ', timeRemaining: 'до окончания',
  completed: 'Завершено', active: '• Идёт',
  sunriseTitle: 'Восход (Шурук)', sunriseSubtitle: 'Запретное время для молитвы',
  scheduleTitle: 'РАСПИСАНИЕ НАМАЗОВ', nextPrayer: 'Следующий',
  home: 'Главная', qibla: 'Кыбла', profile: 'Профиль',
  fajr: 'Фаджр', dhuhr: 'Зухр', asr: 'Аср', maghrib: 'Магриб', isha: 'Иша',
);

const enStrings = AppStrings(
  appTitle: 'Prayer Time', today: 'TODAY', timeRemaining: 'remaining',
  completed: 'Completed', active: '• Active',
  sunriseTitle: 'Sunrise (Shuruq)', sunriseSubtitle: 'Prohibited time for prayer',
  scheduleTitle: 'PRAYER SCHEDULE', nextPrayer: 'Next',
  home: 'Home', qibla: 'Qibla', profile: 'Profile',
  fajr: 'Fajr', dhuhr: 'Dhuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha',
);

const arStrings = AppStrings(
  appTitle: 'مواقيت الصلاة', today: 'اليوم', timeRemaining: 'حتى النهاية',
  completed: 'تم', active: '• جارٍ',
  sunriseTitle: 'الشروق', sunriseSubtitle: 'وقت محرم للصلاة',
  scheduleTitle: 'جدول الصلوات', nextPrayer: 'التالي',
  home: 'الرئيسية', qibla: 'القبلة', profile: 'الملف',
  fajr: 'الفجر', dhuhr: 'الظهر', asr: 'العصر', maghrib: 'المغرب', isha: 'العشاء',
);

const ceStrings = AppStrings(
  appTitle: 'ЛамазанХан', today: 'ТАХАНА', timeRemaining: 'дӀаьхкалц',
  completed: 'Дика ду', active: '• Дӏахьо',
  sunriseTitle: 'Малх бог1аш (Шурукъ)', sunriseSubtitle: 'Ламаз деш йиш йоцу хан',
  scheduleTitle: 'ЛАМАЗАНИЙН РАСПИСАНИ', nextPrayer: 'ТӀаьхьа',
  home: 'Коьрта', qibla: 'Кьибла', profile: 'Профиль',
  fajr: 'Iаьржа ламаз', dhuhr: 'Делкъе ламаз', asr: 'Iаьсар ламаз',
  maghrib: 'Маьхьарш ламаз', isha: 'Пхьоьалг1а ламаз',
);

class AppLocalizations extends InheritedWidget {
  final AppStrings strings;
  final Locale locale;

  const AppLocalizations({
    super.key, required this.strings, required this.locale, required super.child,
  });

  static AppStrings of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppLocalizations>();
    return widget?.strings ?? ruStrings;
  }

  static AppStrings getStrings(String langCode) {
    switch (langCode) {
      case 'ru': return ruStrings;
      case 'en': return enStrings;
      case 'ar': return arStrings;
      case 'ce': return ceStrings;
      default: return ruStrings;
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('ru'), Locale('en'), Locale('ar'), Locale('ce'),
  ];

  static const Map<String, String> languageNames = {
    'ru': 'Русский', 'en': 'English', 'ar': 'العربية', 'ce': 'Нохчийн',
  };

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) => locale != oldWidget.locale;
}