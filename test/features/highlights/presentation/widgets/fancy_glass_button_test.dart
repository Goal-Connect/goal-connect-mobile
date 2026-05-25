import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/highlights/presentation/widgets/fancy_glass_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('FancyGlassButton', () {
    testWidgets('renders icon and label', (tester) async {
      await _pump(
        tester,
        FancyGlassButton(
          icon: Icons.favorite,
          label: '42',
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders with empty label (download idle state)',
        (tester) async {
      await _pump(
        tester,
        FancyGlassButton(
          icon: Icons.download_rounded,
          label: '',
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      // Empty label still renders a Text widget — make sure no stray copy
      // shows up.
      expect(find.text('Download'), findsNothing);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        FancyGlassButton(
          icon: Icons.share,
          label: 'Share',
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('icon turns white when isActive is true', (tester) async {
      await _pump(
        tester,
        FancyGlassButton(
          icon: Icons.favorite,
          label: 'liked',
          color: Colors.red,
          isActive: true,
          onTap: () {},
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.white);
    });

    testWidgets('icon uses tint color when isActive is false', (tester) async {
      await _pump(
        tester,
        FancyGlassButton(
          icon: Icons.favorite_border,
          label: '0',
          color: Colors.red,
          onTap: () {},
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.color, Colors.red);
    });
  });
}
