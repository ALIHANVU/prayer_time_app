/// Класс со ВСЕМИ строками приложения.
/// Каждый язык создаёт свой экземпляр этого класса.
class AppStrings {
  // === Общее ===
  final String appTitle;
  final String today;
  final String timeRemaining;
  final String completed;
  final String active;
  final String next;

  // === Навигация (нижнее меню) ===
  final String home;
  final String qibla;
  final String calendar;
  final String profile;

  // === Названия намазов ===
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  // === Восход ===
  final String sunriseTitle;
  final String sunriseSubtitle;

  // === Главный экран ===
  final String scheduleTitle;
  final String nextPrayer;

  // === Зоны намаза ===
  final String zoneFadila;
  final String zonePermissible;
  final String zoneMakruh;
  final String zoneMissed;

  // === Календарь ===
  final String calendarTitle;
  final String day;
  final String sunrise;
  final String loadingError;
  final String apiError;
  final String noInternet;
  final String tryAgain;

  // === Названия месяцев ===
  final String january;
  final String february;
  final String march;
  final String april;
  final String may;
  final String june;
  final String july;
  final String august;
  final String september;
  final String october;
  final String november;
  final String december;

  // === Дни недели ===
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;

  // === Настройки ===
  final String settingsTitle;
  final String settingsSubtitle;
  final String locationSection;
  final String selectCity;
  final String calculationMethodSection;
  final String calculationMethodTitle;
  final String calculationMethodHint;
  final String languageSection;
  final String aboutSection;
  final String version;
  final String dataSource;
  final String madeWith;
  final String madeWithValue;

  // === Методы расчёта ===
  final String methodKarachi;
  final String methodISNA;
  final String methodMWL;
  final String methodUmmAlQura;
  final String methodEgypt;
  final String methodTehran;
  final String methodGulf;
  final String methodKuwait;
  final String methodQatar;
  final String methodSingapore;
  final String methodFrance;
  final String methodTurkey;
  final String methodRussia;

  // === Кыбла ===
  final String qiblaTitle;
  final String qiblaDirection;
  final String qiblaHowToUse;
  final String qiblaHowToUseDesc;
  final String qiblaAligned;
  final String qiblaCalibrating;
  final String qiblaNoCompass;
  final String qiblaNoCompassDesc;
  final String qiblaKaaba;

  // === Компас — стороны света ===
  final String compassNorth;
  final String compassEast;
  final String compassSouth;
  final String compassWest;

  // === Уведомления ===
  final String notificationPrayerTime;
  final String notificationPrayerStarted;
  final String notificationReminder;
  final String notificationReminderBody;
  final String notificationTest;
  final String notificationTestBody;

  // === Оффлайн-баннер ===
  final String offlineBanner;

  // === Месяцы в родительном падеже (для даты "5 января") ===
  final String januaryOf;
  final String februaryOf;
  final String marchOf;
  final String aprilOf;
  final String mayOf;
  final String juneOf;
  final String julyOf;
  final String augustOf;
  final String septemberOf;
  final String octoberOf;
  final String novemberOf;
  final String decemberOf;

  const AppStrings({
    required this.appTitle,
    required this.today,
    required this.timeRemaining,
    required this.completed,
    required this.active,
    required this.next,
    required this.home,
    required this.qibla,
    required this.calendar,
    required this.profile,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunriseTitle,
    required this.sunriseSubtitle,
    required this.scheduleTitle,
    required this.nextPrayer,
    required this.zoneFadila,
    required this.zonePermissible,
    required this.zoneMakruh,
    required this.zoneMissed,
    required this.calendarTitle,
    required this.day,
    required this.sunrise,
    required this.loadingError,
    required this.apiError,
    required this.noInternet,
    required this.tryAgain,
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.settingsTitle,
    required this.settingsSubtitle,
    required this.locationSection,
    required this.selectCity,
    required this.calculationMethodSection,
    required this.calculationMethodTitle,
    required this.calculationMethodHint,
    required this.languageSection,
    required this.aboutSection,
    required this.version,
    required this.dataSource,
    required this.madeWith,
    required this.madeWithValue,
    required this.methodKarachi,
    required this.methodISNA,
    required this.methodMWL,
    required this.methodUmmAlQura,
    required this.methodEgypt,
    required this.methodTehran,
    required this.methodGulf,
    required this.methodKuwait,
    required this.methodQatar,
    required this.methodSingapore,
    required this.methodFrance,
    required this.methodTurkey,
    required this.methodRussia,
    required this.qiblaTitle,
    required this.qiblaDirection,
    required this.qiblaHowToUse,
    required this.qiblaHowToUseDesc,
    required this.qiblaAligned,
    required this.qiblaCalibrating,
    required this.qiblaNoCompass,
    required this.qiblaNoCompassDesc,
    required this.qiblaKaaba,
    required this.compassNorth,
    required this.compassEast,
    required this.compassSouth,
    required this.compassWest,
    required this.notificationPrayerTime,
    required this.notificationPrayerStarted,
    required this.notificationReminder,
    required this.notificationReminderBody,
    required this.notificationTest,
    required this.notificationTestBody,
    required this.offlineBanner,
    required this.januaryOf,
    required this.februaryOf,
    required this.marchOf,
    required this.aprilOf,
    required this.mayOf,
    required this.juneOf,
    required this.julyOf,
    required this.augustOf,
    required this.septemberOf,
    required this.octoberOf,
    required this.novemberOf,
    required this.decemberOf,
  });

  /// Получить название месяца по номеру (1-12)
  String monthName(int month) {
    const list = [
      '', // 0 — не используется
    ];
    switch (month) {
      case 1: return january;
      case 2: return february;
      case 3: return march;
      case 4: return april;
      case 5: return may;
      case 6: return june;
      case 7: return july;
      case 8: return august;
      case 9: return september;
      case 10: return october;
      case 11: return november;
      case 12: return december;
      default: return '';
    }
  }

  /// Получить название месяца в родительном падеже (для дат)
  String monthNameOf(int month) {
    switch (month) {
      case 1: return januaryOf;
      case 2: return februaryOf;
      case 3: return marchOf;
      case 4: return aprilOf;
      case 5: return mayOf;
      case 6: return juneOf;
      case 7: return julyOf;
      case 8: return augustOf;
      case 9: return septemberOf;
      case 10: return octoberOf;
      case 11: return novemberOf;
      case 12: return decemberOf;
      default: return '';
    }
  }

  /// Получить день недели по номеру (1=Пн, 7=Вс)
  String weekdayName(int weekday) {
    switch (weekday) {
      case 1: return monday;
      case 2: return tuesday;
      case 3: return wednesday;
      case 4: return thursday;
      case 5: return friday;
      case 6: return saturday;
      case 7: return sunday;
      default: return '';
    }
  }

  /// Получить название метода расчёта по его номеру
  String methodName(int method) {
    switch (method) {
      case 1: return methodKarachi;
      case 2: return methodISNA;
      case 3: return methodMWL;
      case 4: return methodUmmAlQura;
      case 5: return methodEgypt;
      case 7: return methodTehran;
      case 8: return methodGulf;
      case 9: return methodKuwait;
      case 10: return methodQatar;
      case 11: return methodSingapore;
      case 12: return methodFrance;
      case 13: return methodTurkey;
      case 14: return methodRussia;
      default: return '?';
    }
  }

  /// Получить локализованное имя намаза по id
  String prayerName(String id) {
    switch (id) {
      case 'fajr': return fajr;
      case 'dhuhr': return dhuhr;
      case 'asr': return asr;
      case 'maghrib': return maghrib;
      case 'isha': return isha;
      default: return id;
    }
  }
}