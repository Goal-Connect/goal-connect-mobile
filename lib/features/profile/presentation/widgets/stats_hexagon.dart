import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_stats.dart';

class StatsHexagon extends StatelessWidget {
  final PlayerStats stats;

  const StatsHexagon({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: const Size(240, 240),
      painter: _HexagonPainter(
        stats: stats,
        isDark: isDark,
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final PlayerStats stats;
  final bool isDark;

  _HexagonPainter({required this.stats, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    final labels = ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'];
    final values = [
      stats.pace, stats.shooting, stats.passing,
      stats.dribbling, stats.defending, stats.physical,
    ];

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (pi / 3) * i - pi / 2;
        final point = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final end = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(center, end, gridPaint);
    }

    final valuePath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final v = (values[i].clamp(0, 99)) / 99.0;
      final r = radius * v;
      final point = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }
    valuePath.close();

    final fillPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(valuePath, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(valuePath, strokePaint);

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final v = (values[i].clamp(0, 99)) / 99.0;
      final r = radius * v;
      final point = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      canvas.drawCircle(point, 4, Paint()..color = AppColors.primaryGreen);
      canvas.drawCircle(point, 2, Paint()..color = Colors.black);
    }

    final textColor = isDark ? Colors.white70 : Colors.black54;
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final labelR = radius + 28;
      final pos = Offset(center.dx + labelR * cos(angle), center.dy + labelR * sin(angle));

      final labelSpan = TextSpan(
        text: labels[i],
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      );
      final labelPainter = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
      labelPainter.paint(canvas, Offset(pos.dx - labelPainter.width / 2, pos.dy - labelPainter.height / 2 - 7));

      final valSpan = TextSpan(
        text: '${values[i]}',
        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w900),
      );
      final valPainter = TextPainter(text: valSpan, textDirection: TextDirection.ltr)..layout();
      valPainter.paint(canvas, Offset(pos.dx - valPainter.width / 2, pos.dy - valPainter.height / 2 + 7));
    }
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter old) =>
      old.stats != stats || old.isDark != isDark;
}
