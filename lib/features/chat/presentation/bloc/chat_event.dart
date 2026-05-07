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
