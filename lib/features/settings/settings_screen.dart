import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/app_preferences.dart';

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

          // Заголовок
          Text('Настройки', style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Text(
            'Город, язык, метод расчёта',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 24),

          // === ГОРОД ===
          Text('МЕСТОПОЛОЖЕНИЕ', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildCityCard(),
          const SizedBox(height: 24),

          // === МЕТОД РАСЧЁТА ===
          Text('МЕТОД РАСЧЁТА', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildMethodCard(),
          const SizedBox(height: 24),

          // === ЯЗЫК ===
          Text('ЯЗЫК', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildLanguageCard(),
          const SizedBox(height: 24),

          // === ИНФОРМАЦИЯ ===
          Text('О ПРИЛОЖЕНИИ', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          _buildInfoCard(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ==========================================
  // Карточка выбора города
  // ==========================================
  Widget _buildCityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Текущий город
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppPreferences.cityName,
                      style: AppTextStyles.prayerName,
                    ),
                    Text(
                      AppPreferences.countryName,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.ringTrack),
          const SizedBox(height: 12),

          // Список городов
          Text(
            'Выберите город:',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...PopularCities.cities.map((city) => _buildCityOption(city)),
        ],
      ),
    );
  }

  Widget _buildCityOption(CityInfo city) {
    final isSelected = AppPreferences.cityName == city.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          AppPreferences.cityName = city.name;
          AppPreferences.countryName = city.country;
          AppPreferences.latitude = city.latitude;
          AppPreferences.longitude = city.longitude;
        });
        // Перезагрузить данные с новыми координатами
        widget.onRefresh();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                city.fullName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Карточка метода расчёта
  // ==========================================
  Widget _buildMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.permissible.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calculate_outlined,
                    color: AppColors.permissible, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Метод расчёта',
                        style: AppTextStyles.prayerName),
                    Text(
                      CalculationMethods
                          .methods[AppPreferences.calculationMethod] ??
                          'Неизвестный',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.ringTrack),
          const SizedBox(height: 8),

          // Информация
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Метод влияет на время Фаджра и Иши. '
                  'Для России рекомендуется «ДУМ России».',
              style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.4,
              ),
            ),
          ),

          ...CalculationMethods.methods.entries.map((entry) {
            final isSelected =
                AppPreferences.calculationMethod == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  AppPreferences.calculationMethod = entry.key;
                });
                widget.onRefresh();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // Карточка выбора языка
  // ==========================================
  Widget _buildLanguageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: AppLocalizations.languageNames.entries.map((entry) {
          final isSelected = AppPreferences.language == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() {});
              widget.onLanguageChanged(entry.key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    const Icon(Icons.check_rounded,
                        color: AppColors.accent, size: 18),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // Карточка «О приложении»
  // ==========================================
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(Icons.info_outline_rounded, 'Версия', '1.0.0'),
          const Divider(height: 20, color: AppColors.ringTrack),
          _infoRow(Icons.cloud_outlined, 'Данные',
              'AlAdhan API'),
          const Divider(height: 20, color: AppColors.ringTrack),
          _infoRow(Icons.favorite_outline_rounded, 'Сделано с ❤️',
              'Для мусульман'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.caption),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}