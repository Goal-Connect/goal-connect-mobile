import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/profile/presentation/widgets/info_chip.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.dark,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: Center(child: SizedBox(width: 120, child: child))),
    ),
  );
}

void main() {
  group('InfoChip', () {
    testWidgets('renders icon, value, and label', (tester) async {
      await _pump(
        tester,
        const InfoChip(
          icon: Icons.sports_soccer,
          label: 'GOALS',
          value: '12',
        ),
      );

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('GOALS'), findsOneWidget);
    });

    testWidgets('icon uses the primary green tint', (tester) async {
      await _pump(
        tester,
        const InfoChip(
          icon: Icons.star,
          label: 'RATING',
          value: '88',
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      // The widget applies a translucent tint of primaryGreen.
      expect(icon.color, AppColors.primaryGreen.withOpacity(0.6));
    });

    testWidgets('value text is white in dark mode', (tester) async {
      await _pump(
        tester,
        const InfoChip(
          icon: Icons.flag,
          label: 'CAPS',
          value: '7',
        ),
      );

      final valueText = tester.widget<Text>(find.text('7'));
      expect(valueText.style?.color, Colors.white);
    });

    testWidgets('value text uses lightText in light mode', (tester) async {
      await _pump(
        tester,
        const InfoChip(
          icon: Icons.flag,
          label: 'CAPS',
          value: '7',
        ),
        brightness: Brightness.light,
      );

      final valueText = tester.widget<Text>(find.text('7'));
      expect(valueText.style?.color, AppColors.lightText);
    });

    testWidgets('long values are wrapped in FittedBox to scale down',
        (tester) async {
      await _pump(
        tester,
        const InfoChip(
          icon: Icons.bolt,
          label: 'MIN PLAYED',
          value: '99999',
        ),
      );

      // Both the value and the label sit inside FittedBox so they shrink to
      // fit a narrow chip — guard the contract.
      expect(find.byType(FittedBox), findsNWidgets(2));
    });
  });
}
