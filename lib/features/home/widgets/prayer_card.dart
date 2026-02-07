import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class PrayerCard extends StatelessWidget {
  final PrayerData prayer;
  final PrayerStatus status;
  final PrayerZone currentZone;
  final String localizedName;

  const PrayerCard({
    super.key,
    required this.prayer, required this.status,
    required this.currentZone, required this.localizedName,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isActive = status == PrayerStatus.active;
    final isCompleted = status == PrayerStatus.completed;

    Color iconBgColor;
    Color iconColor;
    Color timeColor;
    String statusText;

    switch (status) {
      case PrayerStatus.completed:
        iconBgColor = AppColors.completed.withOpacity(0.1);
        iconColor = AppColors.completed;
        timeColor = AppColors.textSecondary;
        statusText = strings.completed;
        break;
      case PrayerStatus.active:
        final zc = PrayerCalculator.getZoneColor(currentZone);
        iconBgColor = zc.withOpacity(0.1);
        iconColor = zc;
        timeColor = zc;
        statusText = '• ${PrayerCalculator.getZoneName(currentZone)}';
        break;
      case PrayerStatus.upcoming:
        iconBgColor = AppColors.textPrimary.withOpacity(0.04);
        iconColor = AppColors.textSecondary;
        timeColor = AppColors.textPrimary;
        statusText = '';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(
            color: PrayerCalculator.getZoneColor(currentZone).withOpacity(0.25), width: 1.5) : null,
        boxShadow: [
          if (isActive) BoxShadow(color: PrayerCalculator.getZoneColor(currentZone).withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))
          else BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(isCompleted ? Icons.check_rounded : prayer.icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizedName, style: AppTextStyles.prayerName.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${prayer.id[0].toUpperCase()}${prayer.id.substring(1)} · ${prayer.durationText}',
                style: AppTextStyles.caption),
          ],
        )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(prayer.startTimeFormatted, style: AppTextStyles.prayerTime.copyWith(color: timeColor)),
            if (statusText.isNotEmpty)
              Text(statusText, style: TextStyle(fontSize: 11,
                  color: isActive ? PrayerCalculator.getZoneColor(currentZone) : AppColors.textSecondary,
                  fontWeight: FontWeight.w500))
            else
              Text(prayer.endTimeFormatted, style: AppTextStyles.caption),
          ],
        ),
      ]),
    );
  }
}