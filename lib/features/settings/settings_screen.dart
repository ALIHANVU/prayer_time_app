import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_preferences.dart';
import '../../core/services/notification_service.dart';
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
  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.settingsTitle,
                style: AppTextStyles.largeTitle.copyWith(color: _txt1(isDark))),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(s.settingsSubtitle,
                style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark))),
          ),

          const SizedBox(height: 24),

          // === МЕСТОПОЛОЖЕНИЕ ===
          _sectionLabel(s.locationSection, isDark),
          const SizedBox(height: 8),
          _card(isDark, children: [
            _settingsRow(
              emoji: '📍', color: AppColors.accent,
              title: s.selectCity, value: AppPreferences.cityName,
              isDark: isDark, onTap: () => _openCityScreen(context),
            ),
            _divider(isDark),
            _settingsRow(
              emoji: '🧮', color: AppColors.permissible,
              title: s.calculationMethodTitle,
              value: s.methodName(AppPreferences.calculationMethod),
              isDark: isDark, onTap: () => _openMethodScreen(context, s),
            ),
          ]),

          const SizedBox(height: 24),

          // === УВЕДОМЛЕНИЯ ===
          _sectionLabel(s.notifySectionGeneral, isDark),
          const SizedBox(height: 8),
          _card(isDark, children: [
            _settingsRow(
              emoji: '🔔', color: AppColors.fadila,
              title: s.notifySectionGeneral,
              value: '',
              isDark: isDark,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _NotificationSettingsScreen(
                  onChanged: () {
                    NotificationService.scheduleAllPrayers(
                      minutesBefore: AppPreferences.reminderMinutes,
                    );
                  },
                )),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // === ОФОРМЛЕНИЕ ===
          _sectionLabel(s.appearanceSection, isDark),
          const SizedBox(height: 8),
          _card(isDark, children: [
            _settingsRow(
              emoji: '🌐', color: const Color(0xFF5856D6),
              title: s.languageSection,
              value: AppLocalizations.languageNames[AppPreferences.language] ?? '',
              isDark: isDark, onTap: () => _openLanguageScreen(context),
            ),
            _divider(isDark),
            _themeRow(isDark, s),
          ]),

          const SizedBox(height: 24),

          // === О ПРИЛОЖЕНИИ ===
          _sectionLabel(s.aboutSection, isDark),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.heroStartDark, AppColors.heroEndDark]
                    : [AppColors.heroStartLight, AppColors.heroEndLight],
              ),
              border: Border.all(color: _sep(isDark), width: 1),
              boxShadow: isDark ? null : [
                BoxShadow(color: AppColors.accent.withOpacity(0.06),
                    blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(children: [
              Positioned(top: -40, right: -30,
                  child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.accent.withOpacity(isDark ? 0.10 : 0.06),
                            Colors.transparent,
                          ])))),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Row(children: [
                      const Text('🕌', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.appTitle, style: AppTextStyles.title3.copyWith(color: _txt1(isDark))),
                        const SizedBox(height: 2),
                        Text('${s.madeWith} ${s.madeWithValue}',
                            style: AppTextStyles.footnote.copyWith(color: _txt3(isDark))),
                      ])),
                    ]),
                    const SizedBox(height: 16),
                    _aboutRow(s.version, '1.0.0', isDark),
                    const SizedBox(height: 8),
                    _aboutRow(s.dataSource, 'AlAdhan API', isDark),
                  ])),
            ]),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    child: Text(text.toUpperCase(),
        style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark))),
  );

  Widget _card(bool isDark, {required List<Widget> children}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: _surf(isDark), borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sep(isDark))),
    child: Column(children: children),
  );

  Widget _divider(bool isDark) => Container(
      height: 0.5, margin: const EdgeInsets.only(left: 60), color: _sep(isDark));

  Widget _settingsRow({
    required String emoji, required Color color,
    required String title, required String value,
    required bool isDark, required VoidCallback onTap,
  }) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    behavior: HitTestBehavior.opaque,
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.12 : 0.10),
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, color: _txt1(isDark)))),
          if (value.isNotEmpty) Text(value, style: AppTextStyles.subheadline.copyWith(color: _txt2(isDark))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: _txt3(isDark)),
        ])),
  );

  Widget _aboutRow(String label, String value, bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Text(label, style: TextStyle(fontSize: 14, color: _txt2(isDark))),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _txt1(isDark))),
    ]),
  );

  Widget _themeRow(bool isDark, AppStrings s) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Container(width: 32, height: 32,
          decoration: BoxDecoration(color: const Color(0xFF5856D6).withOpacity(isDark ? 0.12 : 0.10),
              borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: const Text('🎨', style: TextStyle(fontSize: 16))),
      const SizedBox(width: 12),
      Expanded(child: Text(s.appearanceSection, style: TextStyle(fontSize: 16, color: _txt1(isDark)))),
      _ThemeSegment(isDark: isDark, strings: s, onChanged: widget.onThemeChanged),
    ]),
  );

  void _openCityScreen(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _CitySelectionScreen(
        onCitySelected: (name, country, lat, lon) {
          setState(() {
            AppPreferences.cityName = name; AppPreferences.countryName = country;
            AppPreferences.latitude = lat; AppPreferences.longitude = lon;
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
        onMethodSelected: (id) { setState(() => AppPreferences.calculationMethod = id); widget.onRefresh(); },
      ),
    ));
    setState(() {});
  }

  void _openLanguageScreen(BuildContext ctx) async {
    await Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _LanguageSelectionScreen(onLanguageSelected: widget.onLanguageChanged),
    ));
    setState(() {});
  }
}

// ═══════════════════════════════════════════════════════
// ЭКРАН НАСТРОЙКИ УВЕДОМЛЕНИЙ
// ═══════════════════════════════════════════════════════

class _NotificationSettingsScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const _NotificationSettingsScreen({required this.onChanged});
  @override
  State<_NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<_NotificationSettingsScreen> {
  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt2(bool d) => d ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;
  Color _sep(bool d) => d ? AppColors.separatorDark : AppColors.separator;

  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = AppPreferences.notificationsEnabled;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('🔔', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ═══ Главный выключатель ═══
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppColors.radiusL),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.heroStartDark, AppColors.heroEndDark]
                      : [AppColors.heroStartLight, AppColors.heroEndLight],
                ),
                border: Border.all(color: _sep(isDark), width: 1),
                boxShadow: isDark ? null : [
                  BoxShadow(color: AppColors.accent.withOpacity(0.06),
                      blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Stack(children: [
                Positioned(top: -50, right: -30,
                    child: Container(width: 160, height: 160,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppColors.accent.withOpacity(isDark ? 0.12 : 0.07),
                              Colors.transparent,
                            ])))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 14, 20),
                    child: Row(children: [
                      Container(width: 48, height: 48,
                          decoration: BoxDecoration(
                              color: (enabled ? AppColors.fadila : AppColors.textTertiary).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text(enabled ? '🔔' : '🔕', style: const TextStyle(fontSize: 24))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.notifySectionGeneral,
                            style: AppTextStyles.title3.copyWith(color: _txt1(isDark))),
                        const SizedBox(height: 2),
                        Text(
                          enabled ? s.notifyAtStartDesc : s.notificationsDisabled,
                          style: AppTextStyles.footnote.copyWith(color: _txt3(isDark)),
                        ),
                      ])),
                      Transform.scale(scale: 0.85,
                          child: Switch.adaptive(
                            value: enabled,
                            activeColor: AppColors.fadila,
                            onChanged: (v) => _update(() => AppPreferences.notificationsEnabled = v),
                          )),
                    ])),
              ]),
            ),

            if (!enabled) ...[
              const SizedBox(height: 40),
              Center(child: Column(children: [
                const Text('🔕', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(s.notificationsDisabled,
                    style: AppTextStyles.subheadline.copyWith(color: _txt3(isDark))),
              ])),
            ],

            if (enabled) ...[
              const SizedBox(height: 24),

              // ═══ ОСНОВНЫЕ ═══
              _sectionLabel(s.notifySectionGeneral, isDark),
              const SizedBox(height: 8),
              _card(isDark, children: [
                _toggleRow(
                  emoji: '🕐', color: AppColors.accent,
                  title: s.notifyAtStart, subtitle: s.notifyAtStartDesc,
                  value: AppPreferences.notifyAtPrayerTime, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyAtPrayerTime = v),
                ),
                _divider(isDark),
                _toggleRow(
                  emoji: '⏰', color: AppColors.permissible,
                  title: s.notifyBefore, subtitle: s.notifyBeforeDesc,
                  value: AppPreferences.notifyBeforePrayer, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyBeforePrayer = v),
                ),
                if (AppPreferences.notifyBeforePrayer) ...[
                  _divider(isDark),
                  _minutesPicker(isDark, s),
                ],
                _divider(isDark),
                _toggleRow(
                  emoji: '⚠️', color: AppColors.makruh,
                  title: s.notifyMakruh, subtitle: s.notifyMakruhDesc,
                  value: AppPreferences.notifyMakruhWarning, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyMakruhWarning = v),
                ),
                _divider(isDark),
                _toggleRow(
                  emoji: '⛔', color: const Color(0xFF991B1B),
                  title: s.notifyForbidden, subtitle: s.notifyForbiddenDesc,
                  value: AppPreferences.notifyForbiddenTimes, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyForbiddenTimes = v),
                ),
              ]),

              const SizedBox(height: 24),

              // ═══ НАМАЗЫ — КАЖДЫЙ ОТДЕЛЬНО ═══
              _sectionLabel(s.notifySectionPrayers, isDark),
              const SizedBox(height: 8),
              _card(isDark, children: [
                _prayerToggle('🌙', s.fajr, AppPreferences.notifyFajr, isDark,
                        (v) => _update(() => AppPreferences.notifyFajr = v)),
                _divider(isDark),
                _prayerToggle('☀️', s.dhuhr, AppPreferences.notifyDhuhr, isDark,
                        (v) => _update(() => AppPreferences.notifyDhuhr = v)),
                _divider(isDark),
                _prayerToggle('🌤️', s.asr, AppPreferences.notifyAsr, isDark,
                        (v) => _update(() => AppPreferences.notifyAsr = v)),
                _divider(isDark),
                _prayerToggle('🌅', s.maghrib, AppPreferences.notifyMaghrib, isDark,
                        (v) => _update(() => AppPreferences.notifyMaghrib = v)),
                _divider(isDark),
                _prayerToggle('🌃', s.isha, AppPreferences.notifyIsha, isDark,
                        (v) => _update(() => AppPreferences.notifyIsha = v)),
              ]),

              const SizedBox(height: 24),

              // ═══ ДОПОЛНИТЕЛЬНЫЕ ═══
              _sectionLabel(s.notifySectionOptional, isDark),
              const SizedBox(height: 8),
              _card(isDark, children: [
                _toggleRow(
                  emoji: '🌞', color: AppColors.permissible,
                  title: s.notifyDuhaToggle, subtitle: s.notifyDuhaDesc,
                  value: AppPreferences.notifyDuha, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyDuha = v),
                ),
                _divider(isDark),
                _toggleRow(
                  emoji: '🌙', color: const Color(0xFF6366F1),
                  title: s.notifyTahajjudToggle, subtitle: s.notifyTahajjudDesc,
                  value: AppPreferences.notifyTahajjud, isDark: isDark,
                  onChanged: (v) => _update(() => AppPreferences.notifyTahajjud = v),
                ),
              ]),

              const SizedBox(height: 24),

              // ═══ ТЕСТОВОЕ УВЕДОМЛЕНИЕ ═══
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    NotificationService.showTestNotification();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('✅ ${s.notifyTestBtn}'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('🧪', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(s.notifyTestBtn,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accent)),
                    ]),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    child: Text(text.toUpperCase(),
        style: AppTextStyles.sectionHeader.copyWith(color: _txt3(isDark))),
  );

  Widget _card(bool isDark, {required List<Widget> children}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: _surf(isDark), borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sep(isDark))),
    child: Column(children: children),
  );

  Widget _divider(bool isDark) => Container(
      height: 0.5, margin: const EdgeInsets.only(left: 60), color: _sep(isDark));

  Widget _toggleRow({
    required String emoji, required Color color,
    required String title, required String subtitle,
    required bool value, required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.12 : 0.10),
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _txt1(isDark))),
          const SizedBox(height: 1),
          Text(subtitle, style: TextStyle(fontSize: 12, color: _txt3(isDark)), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        Transform.scale(scale: 0.8,
            child: Switch.adaptive(
              value: value,
              activeColor: color,
              onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); },
            )),
      ]),
    );
  }

  Widget _prayerToggle(String emoji, String name, bool value, bool isDark, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(
                color: (value ? AppColors.fadila : AppColors.textTertiary).withOpacity(isDark ? 0.10 : 0.08),
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500,
            color: value ? _txt1(isDark) : _txt3(isDark)))),
        Transform.scale(scale: 0.8,
            child: Switch.adaptive(
              value: value,
              activeColor: AppColors.fadila,
              onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); },
            )),
      ]),
    );
  }

  Widget _minutesPicker(bool isDark, AppStrings s) {
    final options = [5, 10, 15, 20, 30, 45, 60];
    final current = AppPreferences.reminderMinutes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.permissible.withOpacity(isDark ? 0.12 : 0.10),
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const Text('⏱️', style: TextStyle(fontSize: 16))),
          const SizedBox(width: 12),
          Text(s.notifyMinutesBefore, style: TextStyle(fontSize: 14, color: _txt2(isDark))),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: options.map((m) {
          final active = current == m;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _update(() => AppPreferences.reminderMinutes = m);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent.withOpacity(isDark ? 0.15 : 0.12)
                    : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              child: Text('$m ${s.minutes}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.accent : _txt2(isDark),
                  )),
            ),
          );
        }).toList()),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════
// THEME SEGMENT
// ═══════════════════════════════════════════════════════

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
  void initState() { super.initState(); _current = AppPreferences.themeMode; }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _chip(widget.strings.lightTheme, 'light'),
      _chip(widget.strings.darkTheme, 'dark'),
      _chip(widget.strings.systemTheme, 'system'),
    ]),
  );
  Widget _chip(String label, String value) {
    final active = _current == value;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _current = value); widget.onChanged(value); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: active ? (widget.isDark ? AppColors.surfaceDark : AppColors.surface) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 1))] : null),
        child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? (widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary) : AppColors.textSecondary)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CITY SELECTION SCREEN
// ═══════════════════════════════════════════════════════

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

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;

  @override
  void dispose() { _ctrl.dispose(); _debounce?.cancel(); super.dispose(); }

  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) { setState(() { _results = []; _searching = false; }); return; }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final r = await CitySearchService.search(q);
      if (mounted) setState(() { _results = r; _searching = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(title: Text(s.locationSection),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
              decoration: BoxDecoration(color: _surf(isDark), borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _ctrl, onChanged: _onSearch,
                style: TextStyle(fontSize: 16, color: _txt1(isDark)),
                decoration: InputDecoration(
                    hintText: s.searchCity,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { _ctrl.clear(); _onSearch(''); })
                        : null,
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
              )),
        ),
        Expanded(
          child: _ctrl.text.trim().length >= 2
              ? (_searching
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? Center(child: Text(s.nothingFound))
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final c = _results[i];
                return _tile(c.name, c.displayName, c.latitude, c.longitude, c.country, isDark);
              }))
              : ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(s.popularCities.toUpperCase(), style: AppTextStyles.sectionHeader)),
            ...PopularCities.cities.map((c) => _tile(c.name, c.fullName, c.latitude, c.longitude, c.country, isDark)),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(String name, String display, double lat, double lon, String country, bool isDark) {
    final sel = AppPreferences.cityName == name && (AppPreferences.latitude - lat).abs() < 0.01;
    return GestureDetector(
      onTap: () { widget.onCitySelected(name, country, lat, lon); Navigator.pop(context); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
            color: sel ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF)) : _surf(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? AppColors.accent.withOpacity(0.2) : Colors.transparent)),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(
                  color: (sel ? AppColors.accent : AppColors.textSecondary).withOpacity(isDark ? 0.10 : 0.08),
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(sel ? '✅' : '📍', style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 16,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? AppColors.accent : _txt1(isDark))),
            Text(display, style: AppTextStyles.caption1.copyWith(color: _txt3(isDark)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// METHOD SELECTION SCREEN
// ═══════════════════════════════════════════════════════

class _MethodSelectionScreen extends StatefulWidget {
  final ValueChanged<int> onMethodSelected;
  const _MethodSelectionScreen({required this.onMethodSelected});
  @override
  State<_MethodSelectionScreen> createState() => _MethodSelectionScreenState();
}

class _MethodSelectionScreenState extends State<_MethodSelectionScreen> {
  late int _selected;
  static const _ids = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14];

  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _txt3(bool d) => d ? AppColors.textTertiaryDark : AppColors.textTertiary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;

  @override
  void initState() { super.initState(); _selected = AppPreferences.calculationMethod; }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(title: Text(s.calculationMethodTitle),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.calculationMethodHint, style: AppTextStyles.footnote.copyWith(height: 1.4))),
            ]),
          ),
          ..._ids.map((id) {
            final active = _selected == id;
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = id); widget.onMethodSelected(id); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                    color: active ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF)) : _surf(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: active ? AppColors.accent.withOpacity(0.2) : Colors.transparent)),
                child: Row(children: [
                  Container(width: 32, height: 32,
                      decoration: BoxDecoration(
                          color: (active ? AppColors.accent : _txt3(isDark)).withOpacity(isDark ? 0.10 : 0.08),
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(active ? '✅' : '🧮', style: const TextStyle(fontSize: 14))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.methodName(id), style: TextStyle(
                      fontSize: 16, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.accent : _txt1(isDark)))),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// LANGUAGE SELECTION SCREEN
// ═══════════════════════════════════════════════════════

class _LanguageSelectionScreen extends StatefulWidget {
  final ValueChanged<String> onLanguageSelected;
  const _LanguageSelectionScreen({required this.onLanguageSelected});
  @override
  State<_LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<_LanguageSelectionScreen> {
  late String _selected;
  Color _txt1(bool d) => d ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _surf(bool d) => d ? AppColors.surfaceDark : AppColors.surface;

  @override
  void initState() { super.initState(); _selected = AppPreferences.language; }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(title: Text(s.languageSection),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: AppLocalizations.languageNames.entries.map((e) {
          final active = _selected == e.key;
          String flag;
          switch (e.key) { case 'ru': flag = '🇷🇺'; break; case 'en': flag = '🇬🇧'; break;
            case 'ar': flag = '🇸🇦'; break; case 'ce': flag = '🏔️'; break; default: flag = '🌐'; }
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = e.key); widget.onLanguageSelected(e.key); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                  color: active ? (isDark ? const Color(0xFF141420) : const Color(0xFFF0F2FF)) : _surf(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: active ? AppColors.accent.withOpacity(0.2) : Colors.transparent)),
              child: Row(children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Text(e.value, style: TextStyle(
                    fontSize: 16, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.accent : _txt1(isDark)))),
                if (active) const Text('✅', style: TextStyle(fontSize: 16)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}