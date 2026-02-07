import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.glassWhite, borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.glassBorder, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4),
                BoxShadow(color: AppColors.accent.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (i) => _GlassNavButton(
                  item: items[i], isActive: i == currentIndex, onTap: () => onTap(i))),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavButton extends StatelessWidget {
  final GlassNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassNavButton({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive ? [BoxShadow(color: AppColors.accent.withOpacity(0.12), blurRadius: 12, spreadRadius: -2)] : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(duration: const Duration(milliseconds: 200),
              child: Icon(isActive ? item.activeIcon : item.icon, key: ValueKey(isActive),
                  color: isActive ? AppColors.accent : AppColors.textSecondary, size: isActive ? 26 : 24)),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 200),
              style: AppTextStyles.navLabel.copyWith(
                  color: isActive ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, fontSize: isActive ? 11 : 10),
              child: Text(item.label)),
        ]),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const GlassNavItem({required this.icon, required this.activeIcon, required this.label});
}