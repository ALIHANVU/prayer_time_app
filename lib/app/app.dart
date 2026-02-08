import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../core/utils/prayer_calculator.dart';
import '../core/services/app_preferences.dart';
import '../core/services/notification_service.dart';
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
  int _currentTab = 0;
  bool _isLoading = true;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppPreferences.language;
    _loadPrayerData();
  }

  Future<void> _loadPrayerData() async {
    final success = await PrayerCalculator.updateFromApi(
      latitude: AppPreferences.latitude,
      longitude: AppPreferences.longitude,
      method: AppPreferences.calculationMethod,
    );

    _hasInternet = success;

    if (success) {
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
        themeMode: ThemeMode.light,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _isLoading
                ? const HomeSkeletonScreen()
                : Column(
              children: [
                // Жёлтая полоска если нет интернета
                if (!_hasInternet)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    color: AppColors.permissible.withOpacity(0.15),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 16, color: AppColors.permissible),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.offlineBanner,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
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
                  ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          extendBody: true,
          bottomNavigationBar: GlassNavBar(
            currentIndex: _currentTab,
            onTap: (index) => setState(() => _currentTab = index),
            items: [
              GlassNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: strings.home,
              ),
              GlassNavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: strings.qibla,
              ),
              GlassNavItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: strings.calendar,
              ),
              GlassNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: strings.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}