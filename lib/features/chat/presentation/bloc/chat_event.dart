import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class GetConversationsEvent extends ChatEvent {
  final String userId;
  const GetConversationsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class GetMessagesEvent extends ChatEvent {
  final String conversationId;
  const GetMessagesEvent(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;

  const SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
  });

  @override
  List<Object?> get props => [conversationId, senderId, text];
}
