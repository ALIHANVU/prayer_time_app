import 'package:flutter/material.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

/// ═══════════════════════════════════════════════════════
/// БАННЕР ЗАПРЕТНОГО ВРЕМЕНИ
///
/// Показывается на главном экране в двух случаях:
///
/// 1. АКТИВНОЕ запретное время — красный баннер:
///    «⛔ Восход (шурук) — Нельзя молиться»
///
/// 2. ПРИБЛИЖАЮЩЕЕСЯ запретное время (за 30 мин) — жёлтый:
///    «⚠️ Скоро: Зенит — через 15 мин»
///
/// Три запретных времени (хадис Укбы ибн Амира, Муслим 831):
///  a) Восход — ~15 мин после восхода солнца
///  b) Зенит — когда солнце точно в зените (~5 мин)
///  c) Закат — ~15 мин до полного захода солнца
/// ═══════════════════════════════════════════════════════

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
    final Color borderColor;
    final Color textColor;
    final Color iconBg;
    final String title;
    final String desc;
    final String timeText;

    if (isActive) {
      // Активное запретное время
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF9A9A);
      textColor = const Color(0xFFC62828);
      iconBg = const Color(0x1AC62828);
      title = '⛔ ${forbidden.nameRu}';
      desc = forbidden.descRu;
      timeText = 'до ${forbidden.endFormatted}';
    } else {
      // Приближающееся
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFFFB74D);
      textColor = const Color(0xFFE65100);
      iconBg = const Color(0x1AE65100);

      final nowMin = now != null
          ? now!.hour * 60 + now!.minute
          : 0;
      final diff = forbidden.startMin - nowMin;
      final h = diff ~/ 60;
      final m = diff % 60;
      final timeStr = h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '${m}м';

      title = '⚠️ Скоро: ${forbidden.nameRu}';
      desc = 'Через $timeStr — запретное время для намаза';
      timeText = forbidden.startFormatted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Иконка
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? Icons.block_rounded : Icons.warning_amber_rounded,
                color: textColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      )),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withOpacity(0.8),
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Время
            Text(timeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                )),
          ],
        ),
      ),
    );
  }
}