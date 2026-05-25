import 'dart:ui';
import 'package:flutter/material.dart';

class FancyGlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPulsing;

  /// When true, the button uses [color] as a solid filled background and the
  /// icon renders white — for "active" states like a liked heart.
  final bool isActive;

  const FancyGlassButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.isPulsing = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? color : color.withOpacity(0.15);
    final borderColor = isActive ? color : color.withOpacity(0.3);
    final iconColor = isActive ? Colors.white : color;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: (isPulsing || isActive)
                      ? [
                          BoxShadow(
                            color: color.withOpacity(isActive ? 0.5 : 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(icon, color: iconColor, size: 27),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
