import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

class PrayerCard extends StatefulWidget {
  final PrayerData prayer;
  final PrayerStatus status;
  final PrayerZone currentZone;
  final String localizedName;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.status,
    required this.currentZone,
    required this.localizedName,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  /// Получить локализованное название зоны
  String _getLocalizedZoneName(AppStrings strings, PrayerZone zone) {
    switch (zone) {
      case PrayerZone.fadila:
        return strings.zoneFadila;
      case PrayerZone.permissible:
        return strings.zonePermissible;
      case PrayerZone.makruh:
        return strings.zoneMakruh;
      case PrayerZone.expired:
        return strings.zoneMissed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isActive = widget.status == PrayerStatus.active;
    final isCompleted = widget.status == PrayerStatus.completed;

    Color iconBgColor;
    Color iconColor;
    Color timeColor;
    String statusText;

    switch (widget.status) {
      case PrayerStatus.completed:
        iconBgColor = AppColors.completed.withOpacity(0.1);
        iconColor = AppColors.completed;
        timeColor = AppColors.textSecondary;
        statusText = strings.completed;
        break;
      case PrayerStatus.active:
        final zc = PrayerCalculator.getZoneColor(widget.currentZone);
        iconBgColor = zc.withOpacity(0.1);
        iconColor = zc;
        timeColor = zc;
        statusText = '• ${_getLocalizedZoneName(strings, widget.currentZone)}';
        break;
      case PrayerStatus.upcoming:
        iconBgColor = AppColors.textPrimary.withOpacity(0.04);
        iconColor = AppColors.textSecondary;
        timeColor = AppColors.textPrimary;
        statusText = '';
        break;
    }

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
              color: PrayerCalculator.getZoneColor(widget.currentZone)
                  .withOpacity(0.25),
              width: 1.5,
            )
                : null,
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: PrayerCalculator.getZoneColor(widget.currentZone)
                      .withOpacity(0.1),
                  blurRadius: 16, offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : widget.prayer.icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.localizedName,
                    style: AppTextStyles.prayerName.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.prayer.id[0].toUpperCase()}${widget.prayer.id.substring(1)} · ${widget.prayer.durationText}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.prayer.startTimeFormatted,
                  style: AppTextStyles.prayerTime.copyWith(color: timeColor),
                ),
                if (statusText.isNotEmpty)
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? PrayerCalculator.getZoneColor(widget.currentZone)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(widget.prayer.endTimeFormatted,
                      style: AppTextStyles.caption),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}