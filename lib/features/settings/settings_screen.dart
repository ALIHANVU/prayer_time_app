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

  const SettingsScreen({
    super.key,
    required this.onRefresh,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(strings.settingsTitle, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Text(strings.settingsSubtitle, style: AppTextStyles.caption),
          const SizedBox(height: 24),

          // === Город ===
          _SettingsTile(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.accent,
            title: strings.locationSection,
            subtitle: '${AppPreferences.cityName}, ${AppPreferences.countryName}',
            onTap: () => _openCityScreen(context),
          ),
          const SizedBox(height: 12),

          // === Метод расчёта ===
          _SettingsTile(
            icon: Icons.calculate_outlined,
            iconColor: AppColors.permissible,
            title: strings.calculationMethodTitle,
            subtitle: strings.methodName(AppPreferences.calculationMethod),
            onTap: () => _openMethodScreen(context, strings),
          ),
          const SizedBox(height: 12),

          // === Язык ===
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF5B8DEF),
            title: strings.languageSection,
            subtitle: AppLocalizations.languageNames[AppPreferences.language] ?? 'Русский',
            onTap: () => _openLanguageScreen(context),
          ),
          const SizedBox(height: 24),

          // === О приложении ===
          Text(strings.aboutSection, style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildInfoCard(strings),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _openCityScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _CitySelectionScreen(
        onCitySelected: (name, country, lat, lon) {
          setState(() {
            AppPreferences.cityName = name;
            AppPreferences.countryName = country;
            AppPreferences.latitude = lat;
            AppPreferences.longitude = lon;
          });
          widget.onRefresh();
        },
      )),
    );
    if (result == true) setState(() {});
  }

  void _openMethodScreen(BuildContext context, AppStrings strings) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _MethodSelectionScreen(
        onMethodSelected: (id) {
          setState(() => AppPreferences.calculationMethod = id);
          widget.onRefresh();
        },
      )),
    );
    if (result == true) setState(() {});
  }

  void _openLanguageScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _LanguageSelectionScreen(
        onLanguageSelected: (code) {
          widget.onLanguageChanged(code);
        },
      )),
    );
    if (result == true) setState(() {});
  }

  Widget _buildInfoCard(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(children: [
        _infoRow(Icons.info_outline_rounded, strings.version, '1.0.0'),
        const Divider(height: 20, color: AppColors.ringTrack),
        _infoRow(Icons.cloud_outlined, strings.dataSource, 'AlAdhan API'),
        const Divider(height: 20, color: AppColors.ringTrack),
        _infoRow(Icons.favorite_outline_rounded, strings.madeWith, strings.madeWithValue),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.textSecondary, size: 20),
      const SizedBox(width: 12),
      Text(label, style: AppTextStyles.caption),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
    );
  }
}

// ═══════════════════════════════════════════════
// Компонент-плитка для настроек
// ═══════════════════════════════════════════════

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.prayerName),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          )),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 24),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ЭКРАН ВЫБОРА ГОРОДА (с поиском)
// ═══════════════════════════════════════════════

class _CitySelectionScreen extends StatefulWidget {
  final void Function(String name, String country, double lat, double lon) onCitySelected;

  const _CitySelectionScreen({required this.onCitySelected});

  @override
  State<_CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<_CitySelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CitySearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Ждём 500мс после того как человек перестал печатать
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await CitySearchService.search(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectCity(String name, String country, double lat, double lon) {
    widget.onCitySelected(name, country, lat, lon);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(strings.locationSection,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: strings.selectCity,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearchChanged('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Результаты
          Expanded(
            child: _searchCtrl.text.trim().length >= 2
                ? _buildSearchResults()
                : _buildPopularCities(strings),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Ничего не найдено',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return _buildCityTile(
          city.name,
          city.displayName,
          city.latitude,
          city.longitude,
          city.country,
        );
      },
    );
  }

  Widget _buildPopularCities(AppStrings strings) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Популярные города',
              style: AppTextStyles.sectionLabel),
        ),
        ...PopularCities.cities.map((city) => _buildCityTile(
          city.name,
          city.fullName,
          city.latitude,
          city.longitude,
          city.country,
        )),
      ],
    );
  }

  Widget _buildCityTile(String name, String displayName, double lat, double lon, String country) {
    final isSelected = AppPreferences.cityName == name &&
        (AppPreferences.latitude - lat).abs() < 0.01;

    return GestureDetector(
      onTap: () => _selectCity(name, country, lat, lon),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Icon(
            isSelected ? Icons.location_on_rounded : Icons.location_on_outlined,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              )),
              Text(displayName, style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ЭКРАН ВЫБОРА МЕТОДА РАСЧЁТА
// ═══════════════════════════════════════════════

class _MethodSelectionScreen extends StatefulWidget {
  final ValueChanged<int> onMethodSelected;

  const _MethodSelectionScreen({required this.onMethodSelected});

  @override
  State<_MethodSelectionScreen> createState() => _MethodSelectionScreenState();
}

class _MethodSelectionScreenState extends State<_MethodSelectionScreen> {
  late int _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = AppPreferences.calculationMethod;
  }

  static const methodIds = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(strings.calculationMethodTitle,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Подсказка
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.12)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(
                strings.calculationMethodHint,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              )),
            ]),
          ),
          ...methodIds.map((id) => _buildMethodTile(id, strings)),
        ],
      ),
    );
  }

  Widget _buildMethodTile(int id, AppStrings strings) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMethod = id);
        widget.onMethodSelected(id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Icon(
            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(strings.methodName(id), style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.accent : AppColors.textPrimary,
          ))),
          if (isSelected)
            const Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ЭКРАН ВЫБОРА ЯЗЫКА
// ═══════════════════════════════════════════════

class _LanguageSelectionScreen extends StatefulWidget {
  final ValueChanged<String> onLanguageSelected;

  const _LanguageSelectionScreen({required this.onLanguageSelected});

  @override
  State<_LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<_LanguageSelectionScreen> {
  late String _selectedLang;

  @override
  void initState() {
    super.initState();
    _selectedLang = AppPreferences.language;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(strings.languageSection,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: AppLocalizations.languageNames.entries.map((entry) {
          return _buildLangTile(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildLangTile(String code, String name) {
    final isSelected = _selectedLang == code;

    // Флаг/эмодзи для языка
    String flag;
    switch (code) {
      case 'ru': flag = '🇷🇺'; break;
      case 'en': flag = '🇬🇧'; break;
      case 'ar': flag = '🇸🇦'; break;
      case 'ce': flag = '🏔️'; break;
      default: flag = '🌐';
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedLang = code);
        widget.onLanguageSelected(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.accent : AppColors.textPrimary,
          ))),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
        ]),
      ),
    );
  }
}