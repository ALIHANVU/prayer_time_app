import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;
  final bool minimized;

  const FloatingNavBar({
    super.key, required this.currentIndex, required this.onTap,
    required this.items, this.minimized = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bp = MediaQuery.of(context).padding.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(minimized ? 60 : 12, 0, minimized ? 60 : 12, bp + 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: minimized ? 44 : 58,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(minimized ? 22 : 24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
                borderRadius: BorderRadius.circular(minimized ? 22 : 24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 32, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final active = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () { if (i != currentIndex) HapticFeedback.selectionClick(); onTap(i); },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: minimized ? 10 : 14, vertical: minimized ? 5 : 6),
                            decoration: BoxDecoration(
                              color: active ? AppColors.accent.withOpacity(isDark ? 0.15 : 0.10) : Colors.transparent,
                              borderRadius: BorderRadius.circular(minimized ? 11 : 14),
                            ),
                            child: Icon(
                              active ? items[i].activeIcon : items[i].icon,
                              size: minimized ? 18 : 22,
                              color: active ? AppColors.accent
                                  : (isDark ? AppColors.textTertiaryDark : AppColors.textSecondary),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: minimized ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: minimized
                                ? const SizedBox.shrink()
                                : Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(items[i].label,
                                style: AppTextStyles.navLabel.copyWith(
                                  color: active ? AppColors.accent
                                      : (isDark ? AppColors.textTertiaryDark : AppColors.textSecondary),
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const FloatingNavItem({required this.icon, required this.activeIcon, required this.label});
}