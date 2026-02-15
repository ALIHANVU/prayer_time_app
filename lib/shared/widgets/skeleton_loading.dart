import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const ShimmerBox({super.key, required this.width, required this.height, this.borderRadius = 12});
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value * 3 - 1;
        return Container(
          width: widget.width, height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(v - 1, 0), end: Alignment(v, 0),
              colors: isDark
                  ? [AppColors.surfaceDark, AppColors.surfaceSecondaryDark, AppColors.surfaceDark]
                  : [AppColors.ringTrack, AppColors.surface, AppColors.ringTrack],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class HomeSkeletonScreen extends StatelessWidget {
  const HomeSkeletonScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const ShimmerBox(width: 200, height: 34),
          const SizedBox(height: 8),
          const ShimmerBox(width: 140, height: 16, borderRadius: 8),
          const SizedBox(height: 20),
          const ShimmerBox(width: double.infinity, height: 240, borderRadius: 28),
          const SizedBox(height: 24),
          const ShimmerBox(width: 100, height: 12, borderRadius: 6),
          const SizedBox(height: 12),
          ...List.generate(5, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: ShimmerBox(width: double.infinity, height: 68, borderRadius: 18),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}