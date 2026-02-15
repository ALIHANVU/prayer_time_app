import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppPreferences.language;
    _themeMode = AppPreferences.themeModeEnum;
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
        try {
          await NotificationService.scheduleAllPrayers(
            minutesBefore: AppPreferences.reminderMinutes,
          );
        } catch (e) {
          debugPrint('⚠️ Уведомления: $e');
        }
      }
    } else {
      _hasInternet = false;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void refreshData() {
    setState(() => _isLoading = true);
    _loadPrayerData();
  }

  void changeLanguage(String langCode) {
    AppPreferences.language = langCode;
    setState(() => _currentLanguage = langCode);
  }

  void changeTheme(String mode) {
    AppPreferences.themeMode = mode;
    setState(() => _themeMode = AppPreferences.themeModeEnum);
  }

  /// Вызывается из дочерних экранов при скролле
  void onScrollChanged(bool isScrollingDown) {
    if (_navMinimized != isScrollingDown) {
      setState(() => _navMinimized = isScrollingDown);
    }
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
        home: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.background,
              body: SafeArea(
                bottom: false,
                child: _isLoading
                    ? const HomeSkeletonScreen()
                    : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollUpdateNotification) {
                      final delta = n.scrollDelta ?? 0;
                      if (delta > 2 && !_navMinimized) {
                        setState(() => _navMinimized = true);
                      } else if (delta < -2 && _navMinimized) {
                        setState(() => _navMinimized = false);
                      }
                    }
                    return false;
                  },
                  child: Column(
                    children: [
                      // Оффлайн-баннер
                      if (!_hasInternet)
                        _buildOfflineBanner(strings, isDark),
                      // Контент
                      Expanded(
                        child: IndexedStack(
                          index: _currentTab,
                          children: [
                            const HomeScreen(),
                            const QiblaScreen(),
                            const CalendarScreen(),
                            SettingsScreen(
                              onRefresh: refreshData,
                              onLanguageChanged: changeLanguage,
                              onThemeChanged: changeTheme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              extendBody: true,
              bottomNavigationBar: FloatingNavBar(
                currentIndex: _currentTab,
                minimized: _navMinimized,
                onTap: (i) {
                  setState(() {
                    _currentTab = i;
                    _navMinimized = false;
                  });
                },
                items: [
                  FloatingNavItem(
                    icon: Icons.access_time_outlined,
                    activeIcon: Icons.access_time_filled,
                    label: strings.home,
                  ),
                  FloatingNavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: strings.qibla,
                  ),
                  FloatingNavItem(
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    label: strings.calendar,
                  ),
                  FloatingNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: strings.settings,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(AppStrings strings, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.permissible.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 15, color: AppColors.permissible),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              strings.offlineBanner,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: refreshData,
            child: Icon(Icons.refresh_rounded,
                size: 18, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
