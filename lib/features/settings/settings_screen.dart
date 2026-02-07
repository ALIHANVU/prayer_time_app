import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.person_outline_rounded, size: 64, color: AppColors.accent.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text(strings.profile, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text('Настройки, язык, город, метод расчёта', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    ]));
  }
}