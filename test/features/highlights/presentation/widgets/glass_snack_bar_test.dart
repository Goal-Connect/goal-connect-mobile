import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/highlights/presentation/widgets/glass_snack_bar.dart';

Future<void> _pumpWithTrigger(
  WidgetTester tester,
  void Function(BuildContext) onPressed,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => onPressed(context),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('GlassSnackBar', () {
    testWidgets('success variant shows check icon and message', (tester) async {
      await _pumpWithTrigger(
        tester,
        (ctx) => GlassSnackBar.show(ctx, 'Saved successfully'),
      );

      await tester.tap(find.text('show'));
      await tester.pump(); // enqueue
      await tester.pump(const Duration(milliseconds: 300)); // animate-in

      expect(find.text('Saved successfully'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets('error variant shows error icon and tinted message',
        (tester) async {
      await _pumpWithTrigger(
        tester,
        (ctx) => GlassSnackBar.show(ctx, 'Something went wrong', isError: true),
      );

      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
    });

    testWidgets('showing twice replaces the previous snackbar', (tester) async {
      await _pumpWithTrigger(
        tester,
        (ctx) {
          GlassSnackBar.show(ctx, 'first message');
          GlassSnackBar.show(ctx, 'second message');
        },
      );

      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // clearSnackBars + showSnackBar contract: only the latest is visible.
      expect(find.text('first message'), findsNothing);
      expect(find.text('second message'), findsOneWidget);
    });

    testWidgets('does nothing when there is no ScaffoldMessenger in scope',
        (tester) async {
      // Build a tree WITHOUT MaterialApp / Scaffold to make sure the no-op
      // path is safe.
      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        () => GlassSnackBar.show(capturedContext, 'should be ignored'),
        returnsNormally,
      );
    });
  });
}
