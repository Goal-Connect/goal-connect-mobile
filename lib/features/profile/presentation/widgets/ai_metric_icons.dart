import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goal_connect/core/theme/app_colors.dart';

/// Animated "directions_run" icon for the AI distance-covered tile.
///
/// Uses the standard Material runner glyph but animates a slow bob + faint
/// motion-streak behind it so the runner feels alive instead of static.
class RunningIcon extends StatefulWidget {
  final double size;
  final Color color;
  const RunningIcon({
    super.key,
    this.size = 32,
    this.color = AppColors.primaryGreen,
  });

  @override
  State<RunningIcon> createState() => _RunningIconState();
}

class _RunningIconState extends State<RunningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = _controller.value; // 0..1

          // A "stride" is two footfalls per loop. Bob peaks at each footfall.
          final bob = (math.sin(t * 4 * math.pi).abs()) * -2.0;

          // Subtle forward lean — figure leans into the run, just like real
          // sprinters. Stays constant; gives the "running, not walking" read.
          const leanRadians = -0.12; // ~-7°

          // Streak pulses in/out twice per loop (once per footfall) and
          // shifts behind the runner left-to-right within each stride.
          final streakOpacity =
              (math.sin(t * 4 * math.pi) * 0.5 + 0.5).clamp(0.0, 1.0);
          final localT = (t * 2) % 1.0;
          final streakShift = -3.0 - localT * 6.0;

          // Horizontal scrub — feels like the camera is panning with the
          // runner, the body sways a hair side-to-side per stride.
          final sway = math.sin(t * 2 * math.pi) * 0.8;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Motion streak behind the runner.
              Positioned(
                left: streakShift,
                child: Opacity(
                  opacity: streakOpacity * 0.75,
                  child: Container(
                    width: widget.size * 0.75,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          widget.color.withValues(alpha: 0.0),
                          widget.color.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(sway, bob),
                child: Transform.rotate(
                  angle: leanRadians,
                  child: Icon(
                    Icons.directions_run_rounded,
                    color: widget.color,
                    size: widget.size,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Animated speedometer icon for the AI top-speed tile.
///
/// A miniature radial dial with a sweeping needle that easily oscillates
/// between ~30% and ~95% of its arc. Adds a subtle pulsing glow on the dial
/// rim so the whole tile reads as "live".
class SpeedometerIcon extends StatefulWidget {
  final double size;
  final Color color;
  const SpeedometerIcon({
    super.key,
    this.size = 36,
    this.color = AppColors.primaryGreen,
  });

  @override
  State<SpeedometerIcon> createState() => _SpeedometerIconState();
}

class _SpeedometerIconState extends State<SpeedometerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final t = _controller.value;
          // Smooth ease so the needle pauses naturally at each end.
          final eased = Curves.easeInOutCubic.transform(
            (math.sin(t * 2 * math.pi) + 1) / 2,
          );
          return CustomPaint(
            painter: _SpeedometerPainter(
              color: widget.color,
              progress: eased,
              glow: 0.4 + 0.6 * eased,
            ),
          );
        },
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final Color color;

  /// 0..1, drives the needle angle from start to end of the arc.
  final double progress;

  /// 0..1, brightness of the dial-rim glow.
  final double glow;

  const _SpeedometerPainter({
    required this.color,
    required this.progress,
    required this.glow,
  });

  static const double _startAngle = math.pi * 0.85; // ~153°, lower-left
  static const double _sweep = math.pi * 1.30; // ~234°, lower-right

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = math.min(size.width, size.height) * 0.42;

    // Dim base arc.
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = color.withValues(alpha: 0.25);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, _startAngle, _sweep, false, basePaint);

    // Active arc up to the needle, glowing.
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8
      ..color = color.withValues(alpha: 0.65 + 0.35 * glow);
    canvas.drawArc(rect, _startAngle, _sweep * progress, false, activePaint);

    // Needle.
    final needleAngle = _startAngle + _sweep * progress;
    final needleEnd = Offset(
      center.dx + math.cos(needleAngle) * radius * 0.9,
      center.dy + math.sin(needleAngle) * radius * 0.9,
    );
    final needlePaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Hub dot.
    final hubPaint = Paint()..color = color;
    canvas.drawCircle(center, 1.6, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter old) {
    return old.progress != progress ||
        old.glow != glow ||
        old.color != color;
  }
}
