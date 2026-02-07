import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../features/home/home_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/glass_nav_bar.dart';

class PrayerApp extends StatefulWidget {
  const PrayerApp({super.key});

  @override
  State<PrayerApp> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  String _currentLanguage = 'ru';
  int _currentTab = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  void changeLanguage(String langCode) {
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
            child: IndexedStack(
              index: _currentTab,
              children: _screens,
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
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: strings.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}