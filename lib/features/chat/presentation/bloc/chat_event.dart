import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class GetConversationsEvent extends ChatEvent {
  const GetConversationsEvent();
}

/// Leave thread UI — restores inbox state for the shared [ChatBloc].
class LeaveConversationEvent extends ChatEvent {
  const LeaveConversationEvent();
}

class GetMessagesEvent extends ChatEvent {
  final String conversationId;
  const GetMessagesEvent(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendMessageEvent extends ChatEvent {
  final Conversation peerThread;
  final String text;

  const SendMessageEvent({
    required this.peerThread,
    required this.text,
  });

  @override
  List<Object?> get props => [peerThread.id, text];
}

/// Raw Socket.IO `message:received` payload.
class ChatSocketMessageReceivedEvent extends ChatEvent {
  final Map<String, dynamic> raw;

  const ChatSocketMessageReceivedEvent(this.raw);

  @override
  List<Object?> get props => [raw];
}

/// Raw Socket.IO `message:edited` payload.
class ChatSocketMessageEditedEvent extends ChatEvent {
  final Map<String, dynamic> raw;
  const ChatSocketMessageEditedEvent(this.raw);
  @override
  List<Object?> get props => [raw];
}

/// Raw Socket.IO `message:deleted` payload — `{ "_id": "..." }`.
class ChatSocketMessageDeletedEvent extends ChatEvent {
  final String messageId;
  const ChatSocketMessageDeletedEvent(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

/// Peer started typing in a thread we may be viewing.
class ChatSocketTypingStartEvent extends ChatEvent {
  final String fromUserId;
  const ChatSocketTypingStartEvent(this.fromUserId);
  @override
  List<Object?> get props => [fromUserId];
}

/// Peer stopped typing.
class ChatSocketTypingStopEvent extends ChatEvent {
  final String fromUserId;
  const ChatSocketTypingStopEvent(this.fromUserId);
  @override
  List<Object?> get props => [fromUserId];
}

/// Peer read one or more of our messages.
class ChatSocketMessagesReadEvent extends ChatEvent {
  final List<String> messageIds;
  final String by;
  const ChatSocketMessagesReadEvent({
    required this.messageIds,
    required this.by,
  });
  @override
  List<Object?> get props => [messageIds, by];
}

/// User started typing in the currently-open conversation. Debounced to one
/// `typing:start` per quiet period and a `typing:stop` after the input goes
/// quiet for ~3s.
class TypingNotifiedEvent extends ChatEvent {
  final String peerUserId;
  final bool isTyping;
  const TypingNotifiedEvent({
    required this.peerUserId,
    required this.isTyping,
  });
  @override
  List<Object?> get props => [peerUserId, isTyping];
}

/// Mark the conversation with [peerUserId] as read for the current user.
class MarkConversationReadEvent extends ChatEvent {
  final String peerUserId;
  const MarkConversationReadEvent(this.peerUserId);
  @override
  List<Object?> get props => [peerUserId];
}
