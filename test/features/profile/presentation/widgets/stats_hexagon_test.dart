import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/profile/domain/entities/player_stats.dart';
import 'package:goal_connect/features/profile/presentation/widgets/stats_hexagon.dart';

PlayerStats _stats({
  int pace = 70,
  int shooting = 75,
  int passing = 80,
  int dribbling = 78,
  int defending = 55,
  int physical = 72,
}) {
  return PlayerStats(
    pace: pace,
    shooting: shooting,
    passing: passing,
    dribbling: dribbling,
    defending: defending,
    physical: physical,
    preferredFoot: 'right',
    heightCm: 180,
    weightKg: 75,
    matchesPlayed: 20,
    goals: 5,
    assists: 3,
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('StatsHexagon', () {
    testWidgets('renders a CustomPaint at the documented size', (tester) async {
      await _pump(tester, StatsHexagon(stats: _stats()));

      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(StatsHexagon),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.size, const Size(240, 240));
      expect(paint.painter, isNotNull);
    });

    testWidgets('repaints when stats change', (tester) async {
      await _pump(tester, StatsHexagon(stats: _stats(pace: 60)));

      final firstPainter = tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(StatsHexagon),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter;

      await _pump(tester, StatsHexagon(stats: _stats(pace: 99)));

      final secondPainter = tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(StatsHexagon),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter;

      // Painter instance is new because the stats object changed; the
      // shouldRepaint contract relies on this for invalidation.
      expect(identical(firstPainter, secondPainter), isFalse);
    });

    testWidgets('paints without throwing for zero stats', (tester) async {
      await _pump(
        tester,
        StatsHexagon(
          stats: _stats(
            pace: 0,
            shooting: 0,
            passing: 0,
            dribbling: 0,
            defending: 0,
            physical: 0,
          ),
        ),
      );
      // Reaching here means the painter handled zero values cleanly.
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints without throwing for clamped (>99) stats',
        (tester) async {
      await _pump(
        tester,
        StatsHexagon(
          stats: _stats(
            pace: 150,
            shooting: 200,
            passing: 9999,
            dribbling: 150,
            defending: 120,
            physical: 110,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
