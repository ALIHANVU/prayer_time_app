import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';

/// ═══════════════════════════════════════
/// КАРТОЧКА НАМАЗА В СПИСКЕ
/// ═══════════════════════════════════════

class PrayerCard extends StatelessWidget {
  final PrayerData prayer;
  final String localizedName;
  final PrayerStatus status;
  final PrayerZone zone;
  final bool isActive;
  final DateTime now;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.localizedName,
    required this.status,
    required this.zone,
    required this.isActive,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final Color timeColor;
    String statusText = '';
    Color statusColor = AppColors.textSecondary;

    if (isActive) {
      switch (zone) {
        case PrayerZone.fadila:
          statusText = '● Фадиля';
          statusColor = AppColors.fadila;
          timeColor = AppColors.fadila;
          break;
        case PrayerZone.permissible:
          statusText = '● Допустимо';
          statusColor = AppColors.permissible;
          timeColor = AppColors.permissible;
          break;
        case PrayerZone.makruh:
          statusText = '● Макрух';
          statusColor = AppColors.makruh;
          timeColor = AppColors.makruh;
          break;
        case PrayerZone.expired:
          statusText = '';
          timeColor = AppColors.textPrimary;
          break;
      }
    } else if (status == PrayerStatus.completed) {
      statusText = '✓ Завершён';
      statusColor = AppColors.textMuted;
      timeColor = AppColors.textMuted;
    } else {
      // Upcoming — показываем через сколько
      final nowMin = now.hour * 60 + now.minute;
      final diff = prayer.startMin - nowMin;
      if (diff > 0) {
        final h = diff ~/ 60;
        final m = diff % 60;
        statusText = h > 0 ? 'через $h:${m.toString().padLeft(2,'0')}' : 'через ${m}м';
      }
      statusColor = AppColors.textSecondary;
      timeColor = AppColors.textPrimary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF0FFF5)
            : status == PrayerStatus.completed
            ? AppColors.white.withOpacity(0.6)
            : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: isActive
            ? Border.all(color: AppColors.fadila.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: isActive
            ? [BoxShadow(color: AppColors.fadila.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Иконка
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.fadila.withOpacity(0.12)
                      : status == PrayerStatus.completed
                      ? const Color(0xFFF0F0F0)
                      : const Color(0xFFF0F4ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(prayer.icon,
                    size: 22,
                    color: isActive
                        ? AppColors.fadila
                        : status == PrayerStatus.completed
                        ? AppColors.textMuted
                        : AppColors.textPrimary),
              ),
              const SizedBox(width: 14),

              // Инфо
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizedName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive ? AppColors.fadila : AppColors.textPrimary,
                        )),
                    const SizedBox(height: 1),
                    Text(prayer.durationText,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),

              // Время
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(prayer.startTimeFormatted,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: timeColor,
                      )),
                  if (statusText.isNotEmpty)
                    Text(statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ))
                  else
                    Text(prayer.endTimeFormatted,
                        style: AppTextStyles.caption),
                ],
              ),
            ],
          ),

          // Мини-полоска зон (только для активного)
          if (isActive) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: Row(
                  children: [
                    Flexible(
                      flex: (prayer.fadilaFraction * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.fadila,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(2)),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: (prayer.permissibleFraction * 100).round(),
                      child: Container(color: AppColors.permissible),
                    ),
                    Flexible(
                      flex: (prayer.makruhFraction * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.makruh,
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}