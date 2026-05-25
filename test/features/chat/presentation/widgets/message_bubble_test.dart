import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/chat/domain/entities/message.dart';
import 'package:goal_connect/features/chat/presentation/widgets/message_bubble.dart';

Message _msg({
  String text = 'Hello there',
  bool isMine = false,
  bool isRead = false,
  bool edited = false,
}) {
  return Message(
    id: 'm1',
    conversationId: 'c1',
    senderId: 's1',
    receiverId: 'r1',
    senderName: 'Alice',
    text: text,
    createdAt: DateTime(2026, 5, 24, 10, 30),
    isRead: isRead,
    isMine: isMine,
    edited: edited,
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('MessageBubble', () {
    testWidgets('renders the message text', (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(text: 'Ping!'), isMine: false),
      );
      expect(find.text('Ping!'), findsOneWidget);
    });

    testWidgets('does not show the "edited" tag for unedited messages',
        (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(edited: false), isMine: true),
      );
      expect(find.text('edited'), findsNothing);
    });

    testWidgets('shows the "edited" tag when message.edited is true',
        (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(edited: true), isMine: true),
      );
      expect(find.text('edited'), findsOneWidget);
    });

    testWidgets('shows a single check (sent) for unread own messages',
        (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(isMine: true, isRead: false), isMine: true),
      );
      expect(find.byIcon(Icons.done_rounded), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
    });

    testWidgets('shows the double check (read) for read own messages',
        (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(isMine: true, isRead: true), isMine: true),
      );
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      expect(find.byIcon(Icons.done_rounded), findsNothing);
    });

    testWidgets('does not show read/unread checks on peer messages',
        (tester) async {
      await _pump(
        tester,
        MessageBubble(message: _msg(isMine: false, isRead: true), isMine: false),
      );
      expect(find.byIcon(Icons.done_rounded), findsNothing);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
    });
  });
}
