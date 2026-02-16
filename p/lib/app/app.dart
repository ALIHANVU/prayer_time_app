import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../core/utils/prayer_calculator.dart';
import '../core/services/app_preferences.dart';
import '../core/services/notification_service.dart';
import '../core/services/prayer_api_service.dart';
import '../features/home/home_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/glass_nav_bar.dart';
import '../shared/widgets/skeleton_loading.dart';

class PrayerApp extends StatefulWidget {
  const PrayerApp({super.key});
  @override
  State<PrayerApp> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  late String _currentLanguage;
  late ThemeMode _themeMode;
  int _currentTab = 0;
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _navMinimized = false;

  // Кешируем экраны чтобы не создавать их заново при каждом setState
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppPreferences.language;
    _themeMode = AppPreferences.themeModeEnum;
    _screens = [
      const HomeScreen(),
      const QiblaScreen(),
      const CalendarScreen(),
    ];
    _loadPrayerData();
  }

  Future<void> _loadPrayerData() async {
    final apiData = await PrayerApiService.fetchTodayTimes(
      latitude: AppPreferences.latitude,
      longitude: AppPreferences.longitude,
      method: AppPreferences.calculationMethod,
    );
    if (apiData != null) {
      PrayerCalculator.updateFromApi(apiData);
      _hasInternet = true;
      AppPreferences.markUpdated();
      if (AppPreferences.notificationsEnabled) {
        _scheduleNotifications();
      }
    } else {
      _hasInternet = false;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Выносим планирование уведомлений в отдельный метод
  Future<void> _scheduleNotifications() async {
    try {
      await NotificationService.scheduleAllPrayers(
        minutesBefore: AppPreferences.reminderMinutes,
      );
    } catch (e) {
      debugPrint('Notifications: $e');
    }
  }

  void refreshData() {
    setState(() => _isLoading = true);
    _loadPrayerData();
  }

  void changeLanguage(String c) {
    AppPreferences.language = c;
    setState(() => _currentLanguage = c);
  }

  void changeTheme(String m) {
    AppPreferences.themeMode = m;
    setState(() => _themeMode = AppPreferences.themeModeEnum);
  }

  bool _handleScrollNotification(ScrollNotification n) {
    if (n is ScrollUpdateNotification) {
      final d = n.scrollDelta ?? 0;
      if (d > 2 && !_navMinimized) {
        setState(() => _navMinimized = true);
      } else if (d < -2 && _navMinimized) {
        setState(() => _navMinimized = false);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.getStrings(_currentLanguage);
    return AppLocalizations(
      strings: strings,
      locale: Locale(_currentLanguage),
      child: MaterialApp(
        title: strings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: Builder(builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
            body: SafeArea(
              bottom: false,
              child: _isLoading
                  ? const HomeSkeletonScreen()
                  : NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: Column(children: [
                  if (!_hasInternet) _offlineBanner(strings, isDark),
                  Expanded(
                    child: IndexedStack(
                      index: _currentTab,
                      children: [
                        ..._screens,
                        SettingsScreen(
                          onRefresh: refreshData,
                          onLanguageChanged: changeLanguage,
                          onThemeChanged: changeTheme,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            extendBody: true,
            bottomNavigationBar: FloatingNavBar(
              currentIndex: _currentTab,
              minimized: _navMinimized,
              onTap: (i) => setState(() {
                _currentTab = i;
                _navMinimized = false;
              }),
              items: [
                FloatingNavItem(icon: FlutterIslamicIcons.mosque, activeIcon: FlutterIslamicIcons.solidMosque, label: strings.home),
                FloatingNavItem(icon: FlutterIslamicIcons.kaaba, activeIcon: FlutterIslamicIcons.solidKaaba, label: strings.qibla),
                FloatingNavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: strings.calendar),
                FloatingNavItem(icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded, label: strings.settings),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _offlineBanner(AppStrings s, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.permissible.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.permissible),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            s.offlineBanner,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: refreshData,
          child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.accent),
        ),
      ]),
    );
  }
}