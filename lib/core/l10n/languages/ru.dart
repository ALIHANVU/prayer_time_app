import '../app_strings.dart';

const ruStrings = AppStrings(
  // === Общее ===
  appTitle: 'Время намаза',
  today: 'Сегодня',
  timeRemaining: 'до конца',
  completed: 'Завершён',
  active: 'Идёт',
  next: 'Следующий',
  until: 'до',

  // === Навигация ===
  home: 'Главная',
  qibla: 'Кыбла',
  calendar: 'Календарь',
  settings: 'Настройки',

  // === Намазы ===
  fajr: 'Фаджр',
  dhuhr: 'Зухр',
  asr: 'Аср',
  maghrib: 'Магриб',
  isha: 'Иша',

  // === Восход ===
  sunriseTitle: 'Восход',
  sunriseSubtitle: 'Запретное время для намаза',

  // === Главный экран ===
  scheduleTitle: 'Расписание',
  nextPrayer: 'Следующий намаз',
  noPrayerNow: 'Сейчас нет активного намаза',
  allCompleted: 'Все намазы на сегодня завершены',

  // === Зоны ===
  zoneFadila: 'Фадиля',
  zonePermissible: 'Допустимо',
  zoneMakruh: 'Макрух',
  zoneMissed: 'Упущен',

  // === Календарь ===
  calendarTitle: 'Календарь',
  day: 'День',
  sunrise: 'Восход',
  loadingError: 'Ошибка загрузки',
  apiError: 'Ошибка сервера',
  noInternet: 'Нет подключения к интернету',
  tryAgain: 'Повторить',

  // === Месяцы ===
  january: 'Январь',
  february: 'Февраль',
  march: 'Март',
  april: 'Апрель',
  may: 'Май',
  june: 'Июнь',
  july: 'Июль',
  august: 'Август',
  september: 'Сентябрь',
  october: 'Октябрь',
  november: 'Ноябрь',
  december: 'Декабрь',

  // === Месяцы (родительный) ===
  januaryOf: 'января',
  februaryOf: 'февраля',
  marchOf: 'марта',
  aprilOf: 'апреля',
  mayOf: 'мая',
  juneOf: 'июня',
  julyOf: 'июля',
  augustOf: 'августа',
  septemberOf: 'сентября',
  octoberOf: 'октября',
  novemberOf: 'ноября',
  decemberOf: 'декабря',

  // === Дни недели ===
  monday: 'Понедельник',
  tuesday: 'Вторник',
  wednesday: 'Среда',
  thursday: 'Четверг',
  friday: 'Пятница',
  saturday: 'Суббота',
  sunday: 'Воскресенье',

  // === Настройки ===
  settingsTitle: 'Настройки',
  settingsSubtitle: 'Город, язык, метод расчёта',
  locationSection: 'Местоположение',
  selectCity: 'Выберите город',
  calculationMethodSection: 'Метод расчёта',
  calculationMethodTitle: 'Метод расчёта',
  calculationMethodHint:
  'Метод влияет на время Фаджра и Иши. Для России рекомендуется «ДУМ России».',
  languageSection: 'Язык',
  appearanceSection: 'Оформление',
  darkTheme: 'Тёмная',
  lightTheme: 'Светлая',
  systemTheme: 'Как в системе',
  aboutSection: 'О приложении',
  version: 'Версия',
  dataSource: 'Источник данных',
  madeWith: 'Сделано с любовью',
  madeWithValue: 'для мусульман',
  notificationsSection: 'Уведомления',
  notificationsEnabled: 'Включены',
  reminderBefore: 'Напоминание за',
  minutes: 'мин',

  // === Методы расчёта ===
  methodKarachi: 'Карачи',
  methodISNA: 'ISNA (Сев. Америка)',
  methodMWL: 'Мусульманская Всемирная Лига',
  methodUmmAlQura: 'Умм аль-Кура (Мекка)',
  methodEgypt: 'Египет',
  methodTehran: 'Тегеран',
  methodGulf: 'Персидский залив',
  methodKuwait: 'Кувейт',
  methodQatar: 'Катар',
  methodSingapore: 'Сингапур',
  methodFrance: 'UOIF (Франция)',
  methodTurkey: 'Диянет (Турция)',
  methodRussia: 'ДУМ России',

  // === Кыбла ===
  qiblaTitle: 'Кыбла',
  qiblaDirection: 'Направление',
  qiblaHowToUse: 'Как пользоваться',
  qiblaHowToUseDesc:
  'Держите телефон горизонтально. Стрелка показывает направление на Каабу. Зелёный цвет означает, что вы смотрите в сторону Кыблы.',
  qiblaAligned: 'Вы смотрите на Кыблу!',
  qiblaCalibrating: 'Калибровка компаса…',
  qiblaNoCompass: 'Компас недоступен',
  qiblaNoCompassDesc: 'На этом устройстве нет датчика компаса.',
  qiblaKaaba: 'Кааба',

  // === Компас ===
  compassNorth: 'С',
  compassEast: 'В',
  compassSouth: 'Ю',
  compassWest: 'З',

  // === Уведомления ===
  notificationPrayerTime: 'Время намаза',
  notificationPrayerStarted: 'Наступило время',
  notificationReminder: 'Через',
  notificationReminderBody: 'начнётся в',
  notificationTest: 'Тестовое уведомление',
  notificationTestBody:
  'Уведомления работают! Вы будете получать напоминания о намазах.',

  // === Оффлайн ===
  offlineBanner: 'Нет интернета — показаны приблизительные данные',

  // === Запретные времена ===
  forbiddenActive: 'Запретное время',
  forbiddenSoon: 'Скоро запретное время',
  forbiddenPrayerProhibited: 'Намаз запрещён',
  forbiddenSunriseName: 'Восход (шурук)',
  forbiddenZenithName: 'Зенит (завваль)',
  forbiddenSunsetName: 'Закат',
  forbiddenUntil: 'до',
  forbiddenIn: 'через',

  // === Поиск ===
  searchCity: 'Поиск города…',
  popularCities: 'Популярные города',
  nothingFound: 'Ничего не найдено',
);