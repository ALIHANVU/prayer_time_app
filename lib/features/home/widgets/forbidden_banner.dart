import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class ForbiddenBanner extends StatelessWidget {
  final ForbiddenTime forbidden;
  final bool isActive;
  final DateTime? now;
  final AppStrings strings;

  const ForbiddenBanner({
    super.key,
    required this.forbidden,
    required this.isActive,
    this.now,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color iconColor;
    final String title;
    final String subtitle;

    if (isActive) {
      bgColor = AppColors.makruh.withOpacity(0.1);
      iconColor = AppColors.makruh;
      title = strings.forbiddenActive;
      subtitle = '${strings.forbiddenPrayerProhibited} · ${strings.forbiddenUntil} ${forbidden.endFormatted}';
    } else {
      bgColor = AppColors.permissible.withOpacity(0.1);
      iconColor = AppColors.permissible;
      final nowMin = now != null ? now!.hour * 60 + now!.minute : 0;
      final diff = forbidden.startMin - nowMin;
      final m = diff % 60;
      final h = diff ~/ 60;
      final timeStr = h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '$m ${strings.minutes}';
      title = strings.forbiddenSoon;
      subtitle = '${strings.forbiddenIn} $timeStr · ${forbidden.startFormatted}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.block_rounded : Icons.schedule_rounded,
              color: iconColor, size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: iconColor)),
                  Text(subtitle, style: TextStyle(
                      fontSize: 12, color: iconColor.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}