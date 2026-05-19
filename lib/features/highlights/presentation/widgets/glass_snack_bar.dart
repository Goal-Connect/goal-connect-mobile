import 'dart:ui';

import 'package:flutter/material.dart';

/// SnackBar styled to match [FancyGlassButton]: translucent white surface with a
/// backdrop blur, hairline border, and optional accent tint for errors/success.
class GlassSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Color? accent,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final tint = accent ?? (isError ? const Color(0xFFFF5A5F) : Colors.white);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          content: _GlassContent(message: message, tint: tint, isError: isError),
        ),
      );
  }
}

class _GlassContent extends StatelessWidget {
  final String message;
  final Color tint;
  final bool isError;

  const _GlassContent({
    required this.message,
    required this.tint,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tint.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tint.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: tint.withOpacity(isError ? 0.35 : 0.2),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: tint,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
