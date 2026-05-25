import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/onboarding/presentation/widgets/fancy_background.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: FancyBackground()),
    ),
  );
}

void main() {
  group('FancyBackground', () {
    testWidgets('paints the dark backdrop fill', (tester) async {
      await _pump(tester);

      // The first Container in the Stack is a flat color fill.
      final fill = tester.widget<Container>(
        find.descendant(
          of: find.byType(FancyBackground),
          matching: find.byType(Container),
        ).first,
      );
      expect(fill.color, AppColors.darkBg);
    });

    testWidgets('lays out as a Stack with two positioned glow accents',
        (tester) async {
      await _pump(tester);

      expect(
        find.descendant(
          of: find.byType(FancyBackground),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
      // Two Positioned glow circles (top-right + bottom-left).
      expect(
        find.descendant(
          of: find.byType(FancyBackground),
          matching: find.byType(Positioned),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('renders without exceptions and stays sized to parent',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: FancyBackground(),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final size = tester.getSize(find.byType(FancyBackground));
      expect(size.width, 400);
      expect(size.height, 500);
    });
  });
}
