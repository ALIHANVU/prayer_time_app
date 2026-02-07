import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.explore_outlined, size: 64, color: AppColors.accent.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text(strings.qibla, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text('Скоро здесь будет компас Кыблы', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    ]));
  }
}