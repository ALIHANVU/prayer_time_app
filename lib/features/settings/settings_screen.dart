import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_preferences.dart';
import '../../core/services/city_search_service.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onRefresh,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              s.settingsTitle,
              style: AppTextStyles.largeTitle.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader(s.locationSection),
          _groupedSection(isDark, [
            _settingsRow(Icons.location_on_outlined, AppColors.accent,
                s.selectCity, AppPreferences.cityName, isDark,
                    () => _openCityScreen(context)),
            _divider(isDark),
            _settingsRow(Icons.calculate_outlined, AppColors.permissible,
                s.calculationMethodTitle,
                s.methodName(AppPreferences.calculationMethod), isDark,
                    () => _openMethodScreen(context, s)),
          ]),
          const SizedBox(height: 24),

          _sectionHeader(s.appearanceSection),
          _groupedSection(isDark, [
            _settingsRow(Icons.language_rounded, const Color(0xFF5856D6),
                s.languageSection,
                AppLocalizations.languageNames[AppPreferences.language] ?? '',
                isDark, () => _openLanguageScreen(context)),
            _divider(isDark),
            _themeRow(isDark, s),
          ]),
          const SizedBox(height: 24),

          _sectionHeader(s.aboutSection),
          _groupedSection(isDark, [
            _infoRow(s.version, '1.0.0', isDark),
            _divider(isDark),
            _infoRow(s.dataSource, 'AlAdhan API', isDark),
            _divider(isDark),
            _infoRow(s.madeWith, s.madeWithValue, isDark),
          ]),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 0, 20, 6),
      child: Text(text.toUpperCase(), style: AppTextStyles.sectionHeader),
    );
  }

  Widget _groupedSection(bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 52),
      color: isDark ? AppColors.separatorDark : AppColors.separator,
    );
  }

  Widget _settingsRow(IconData icon, Color iconColor, String title,
      String value, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                  color: iconColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 16,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ),
            Text(value, style: AppTextStyles.subheadline),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const Spacer(),
          Text(value, style: AppTextStyles.subheadline),
        ],
      ),
    );
  }

  Widget _themeRow(bool isDark, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF5856D6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dark_mode_outlined, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(s.appearanceSection, style: TextStyle(fontSize: 16,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ),
          _ThemeSegment(isDark: isDark, strings: s, onChanged: widget.onThemeChanged),
        ],
      ),
    );
  }

  void _openCityScreen(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _CitySelectionScreen(
        onCitySelected: (name, country, lat, lon) {
          setState(() {
            AppPreferences.cityName = name;
            AppPreferences.countryName = country;
            AppPreferences.latitude = lat;
            AppPreferences.longitude = lon;
          });
          widget.onRefresh();
        },
      ),
    ));
    setState(() {});
  }

  void _openMethodScreen(BuildContext ctx, AppStrings s) async {
    await Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _MethodSelectionScreen(
        onMethodSelected: (id) {
          setState(() => AppPreferences.calculationMethod = id);
          widget.onRefresh();
        },
      ),
    ));
    setState(() {});
  }

  void _openLanguageScreen(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _LanguageSelectionScreen(
        onLanguageSelected: widget.onLanguageChanged,
      ),
    ));
    setState(() {});
  }
}

// ═══ Theme segment control ═══

class _ThemeSegment extends StatefulWidget {
  final bool isDark;
  final AppStrings strings;
  final ValueChanged<String> onChanged;
  const _ThemeSegment({required this.isDark, required this.strings, required this.onChanged});
  @override
  State<_ThemeSegment> createState() => _ThemeSegmentState();
}

class _ThemeSegmentState extends State<_ThemeSegment> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = AppPreferences.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(widget.strings.lightTheme, 'light'),
          _chip(widget.strings.darkTheme, 'dark'),
          _chip(widget.strings.systemTheme, 'system'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final active = _current == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _current = value);
        widget.onChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? (widget.isDark ? AppColors.surfaceDark : AppColors.surface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active
              ? (widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
              : AppColors.textSecondary,
        )),
      ),
    );
  }
}

// ═══ City selection screen ═══

class _CitySelectionScreen extends StatefulWidget {
  final void Function(String, String, double, double) onCitySelected;
  const _CitySelectionScreen({required this.onCitySelected});
  @override
  State<_CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<_CitySelectionScreen> {
  final _ctrl = TextEditingController();
  List<CitySearchResult> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() { _ctrl.dispose(); _debounce?.cancel(); super.dispose(); }

  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() { _results = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final r = await CitySearchService.search(q);
      if (mounted) setState(() { _results = r; _searching = false; });
    });
  }

  void _select(String name, String country, double lat, double lon) {
    widget.onCitySelected(name, country, lat, lon);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(s.locationSection),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _ctrl,
                onChanged: _onSearch,
                style: TextStyle(fontSize: 16,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: s.searchCity,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () { _ctrl.clear(); _onSearch(''); },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _ctrl.text.trim().length >= 2
                ? _buildSearchResults(isDark, s)
                : _buildPopular(isDark, s),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark, AppStrings s) {
    if (_searching) return const Center(child: CircularProgressIndicator());
    if (_results.isEmpty) {
      return Center(child: Text(s.nothingFound, style: AppTextStyles.subheadline));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final c = _results[i];
        return _cityTile(c.name, c.displayName, c.latitude, c.longitude, c.country, isDark);
      },
    );
  }

  Widget _buildPopular(bool isDark, AppStrings s) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(s.popularCities.toUpperCase(), style: AppTextStyles.sectionHeader),
        ),
        ...PopularCities.cities.map((c) =>
            _cityTile(c.name, c.fullName, c.latitude, c.longitude, c.country, isDark)),
      ],
    );
  }

  Widget _cityTile(String name, String display, double lat, double lon, String country, bool isDark) {
    final selected = AppPreferences.cityName == name && (AppPreferences.latitude - lat).abs() < 0.01;
    return GestureDetector(
      onTap: () => _select(name, country, lat, lon),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle_outline : Icons.location_on_outlined,
                color: selected ? AppColors.accent : AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.accent : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                Text(display, style: AppTextStyles.caption1, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            if (selected) Icon(Icons.check, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

// ═══ Method selection screen ═══

class _MethodSelectionScreen extends StatefulWidget {
  final ValueChanged<int> onMethodSelected;
  const _MethodSelectionScreen({required this.onMethodSelected});
  @override
  State<_MethodSelectionScreen> createState() => _MethodSelectionScreenState();
}

class _MethodSelectionScreenState extends State<_MethodSelectionScreen> {
  late int _selected;
  static const _ids = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14];

  @override
  void initState() { super.initState(); _selected = AppPreferences.calculationMethod; }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(s.calculationMethodTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(s.calculationMethodHint,
                style: AppTextStyles.footnote.copyWith(height: 1.4)),
          ),
          ..._ids.map((id) {
            final active = _selected == id;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selected = id);
                widget.onMethodSelected(id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(active ? Icons.check_circle : Icons.circle_outlined,
                        color: active ? AppColors.accent : AppColors.textTertiary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s.methodName(id), style: TextStyle(
                        fontSize: 16, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══ Language selection screen ═══

class _LanguageSelectionScreen extends StatefulWidget {
  final ValueChanged<String> onLanguageSelected;
  const _LanguageSelectionScreen({required this.onLanguageSelected});
  @override
  State<_LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<_LanguageSelectionScreen> {
  late String _selected;
  @override
  void initState() { super.initState(); _selected = AppPreferences.language; }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(s.languageSection),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: AppLocalizations.languageNames.entries.map((e) {
          final active = _selected == e.key;
          String flag;
          switch (e.key) {
            case 'ru': flag = '🇷🇺'; break;
            case 'en': flag = '🇬🇧'; break;
            case 'ar': flag = '🇸🇦'; break;
            case 'ce': flag = '🏔️'; break;
            default: flag = '🌐';
          }
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selected = e.key);
              widget.onLanguageSelected(e.key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.value, style: TextStyle(
                      fontSize: 16, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                  if (active) Icon(Icons.check, color: AppColors.accent, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}