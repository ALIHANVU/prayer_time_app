import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class PrayerCard extends StatelessWidget {
  final PrayerData prayer;
  final String localizedName;
  final PrayerStatus status;
  final PrayerZone zone;
  final bool isActive;
  final DateTime now;

  const PrayerCard({
    super.key, required this.prayer, required this.localizedName,
    required this.status, required this.zone,
    required this.isActive, required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppLocalizations.of(context);

    Color timeColor;
    String statusText = '';
    Color statusColor = AppColors.textSecondary;

    if (isActive) {
      switch (zone) {
        case PrayerZone.fadila:
          statusText = s.zoneFadila; statusColor = AppColors.fadila; timeColor = AppColors.fadila; break;
        case PrayerZone.permissible:
          statusText = s.zonePermissible; statusColor = AppColors.permissible; timeColor = AppColors.permissible; break;
        case PrayerZone.makruh:
          statusText = s.zoneMakruh; statusColor = AppColors.makruh; timeColor = AppColors.makruh; break;
        case PrayerZone.expired:
          statusText = ''; timeColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary; break;
      }
    } else if (status == PrayerStatus.completed) {
      statusText = s.completed;
      statusColor = AppColors.textTertiary;
      timeColor = AppColors.textTertiary;
    } else {
      final nowMin = now.hour * 60 + now.minute;
      final diff = prayer.startMin - nowMin;
      if (diff > 0) {
        final h = diff ~/ 60; final m = diff % 60;
        statusText = h > 0
            ? '${s.forbiddenIn} $h:${m.toString().padLeft(2, '0')}'
            : '${s.forbiddenIn} $m ${s.minutes}';
      }
      statusColor = AppColors.textSecondary;
      timeColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4), // iOS 26: больше spacing
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark
            ? statusColor.withOpacity(0.08)
            : statusColor.withOpacity(0.05))
            : (isDark ? AppColors.surfaceDark : AppColors.surface),
        borderRadius: BorderRadius.circular(AppColors.radiusS), // 16px iOS 26
      ),
      child: Row(
        children: [
          // Индикатор — iOS 26: толще, скруглённее
          Container(
            width: 4, height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? statusColor
                  : status == PrayerStatus.completed
                  ? AppColors.textTertiary.withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizedName, style: TextStyle(
                  fontSize: 17, // iOS 26 body size
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: status == PrayerStatus.completed
                      ? AppColors.textTertiary
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                )),
                if (statusText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(statusText, style: TextStyle(
                        fontSize: 13, color: statusColor,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400)),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(prayer.startTimeFormatted,
                  style: AppTextStyles.prayerTime.copyWith(color: timeColor)),
              Text(prayer.endTimeFormatted, style: AppTextStyles.caption1),
            ],
          ),
        ],
      ),
    );
  }
}