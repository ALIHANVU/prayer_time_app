import 'package:flutter/material.dart';

/// Один мерцающий блок. Используется как «заглушка» вместо текста/картинки.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final val = _ctrl.value * 3 - 1; // от -1 до 2
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(val - 1, 0),
              end: Alignment(val, 0),
              colors: const [
                Color(0xFFE8F0EC),
                Color(0xFFF7FBF9),
                Color(0xFFE8F0EC),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Обёртка над AnimatedBuilder (стандартный Flutter виджет)
class AnimatedBuilder extends StatelessWidget {
  final Listenable listenable;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: builder,
    );
  }
}

/// ====================================================
/// Скелетон главного экрана
/// Показывается пока грузятся данные из интернета.
/// Повторяет форму настоящего экрана: заголовок, дата,
/// круг, зоны, восход, 5 карточек намазов.
/// ====================================================
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
          const SizedBox(height: 8),

          // ─── Заголовок ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 180, height: 28),
                  SizedBox(height: 8),
                  ShimmerBox(width: 130, height: 14, borderRadius: 7),
                ],
              ),
              const ShimmerBox(width: 44, height: 44, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Карточка даты ───
          const Center(
            child: ShimmerBox(width: 260, height: 70, borderRadius: 20),
          ),
          const SizedBox(height: 24),

          // ─── Круг прогресса ───
          const Center(
            child: ShimmerBox(width: 230, height: 230, borderRadius: 115),
          ),
          const SizedBox(height: 12),

          // ─── Легенда зон ───
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ShimmerBox(width: 60, height: 12, borderRadius: 6),
              SizedBox(width: 16),
              ShimmerBox(width: 70, height: 12, borderRadius: 6),
              SizedBox(width: 16),
              ShimmerBox(width: 55, height: 12, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Карточка восхода ───
          const ShimmerBox(
            width: double.infinity,
            height: 60,
            borderRadius: 16,
          ),
          const SizedBox(height: 24),

          // ─── Заголовок расписания ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 160, height: 12, borderRadius: 6),
              ShimmerBox(width: 100, height: 12, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),

          // ─── 5 карточек намазов ───
          ...List.generate(
            5,
                (i) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ShimmerBox(
                width: double.infinity,
                height: 70,
                borderRadius: 16,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}