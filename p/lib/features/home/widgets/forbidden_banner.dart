import 'package:flutter/material.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/l10n/app_localizations.dart';

/// Больше не используется — запретное время теперь в HeroCard
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}