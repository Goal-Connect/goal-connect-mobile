import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;
  const ConversationsLoaded(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<Message> messages;
  const MessagesLoaded({required this.conversationId, required this.messages});
  @override
  List<Object?> get props => [conversationId, messages];
}

class MessageSending extends ChatState {
  final String conversationId;
  final List<Message> messages;
  const MessageSending({required this.conversationId, required this.messages});
  @override
  List<Object?> get props => [conversationId, messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
