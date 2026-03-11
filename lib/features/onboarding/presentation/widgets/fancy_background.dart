import 'package:flutter/material.dart';
import 'package:goal_connect/core/theme/app_colors.dart';

class FancyBackground extends StatelessWidget {
  const FancyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.darkBg),
        Positioned(
          top: -100,
          right: -50,
          child: _GlowCircle(
            color: AppColors.primaryGreen.withOpacity(0.15),
            size: 300,
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: _GlowCircle(
            color: AppColors.accentGold.withOpacity(0.1),
            size: 250,
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}
