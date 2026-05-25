import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/auth/presentation/widgets/pending_approval_dialog.dart';

Future<void> _pumpDialog(
  WidgetTester tester, {
  required String email,
  required bool justRegistered,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => PendingApprovalDialog.show(
                context,
                email: email,
                justRegistered: justRegistered,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('PendingApprovalDialog', () {
    testWidgets(
        'just-registered variant shows "Application received" with email',
        (tester) async {
      await _pumpDialog(
        tester,
        email: 'scout@example.com',
        justRegistered: true,
      );

      expect(find.text('Application received'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
      expect(
        find.textContaining('scout@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('returning-user variant shows "Approval pending" with email',
        (tester) async {
      await _pumpDialog(
        tester,
        email: 'pending@example.com',
        justRegistered: false,
      );

      expect(find.text('Approval pending'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      expect(
        find.textContaining('pending@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('tapping "Got it" dismisses the dialog', (tester) async {
      await _pumpDialog(
        tester,
        email: 'someone@example.com',
        justRegistered: true,
      );

      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('barrier is non-dismissible (tap outside does not close)',
        (tester) async {
      await _pumpDialog(
        tester,
        email: 'someone@example.com',
        justRegistered: false,
      );

      // Tap at a corner well outside the dialog content.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
