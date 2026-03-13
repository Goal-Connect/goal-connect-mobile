import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUsecase getConversations;
  final GetMessagesUsecase getMessages;
  final SendMessageUsecase sendMessage;

  ChatBloc({
    required this.getConversations,
    required this.getMessages,
    required this.sendMessage,
  }) : super(ChatInitial()) {
    on<GetConversationsEvent>((event, emit) async {
      emit(ChatLoading());
      final result = await getConversations(event.userId);
      result.fold(
        (failure) => emit(const ChatError('Failed to load conversations')),
        (conversations) => emit(ConversationsLoaded(conversations)),
      );
    });

    on<GetMessagesEvent>((event, emit) async {
      emit(ChatLoading());
      final result = await getMessages(event.conversationId);
      result.fold(
        (failure) => emit(const ChatError('Failed to load messages')),
        (messages) => emit(
          MessagesLoaded(
              conversationId: event.conversationId, messages: messages),
        ),
      );
    });

    on<SendMessageEvent>((event, emit) async {
      final current = state;
      final currentMessages =
          current is MessagesLoaded ? current.messages : [];

      emit(MessageSending(
        conversationId: event.conversationId,
        messages: List.from(currentMessages),
      ));

      final result = await sendMessage(
        conversationId: event.conversationId,
        senderId: event.senderId,
        senderName: event.senderName,
        text: event.text,
      );

      result.fold(
        (failure) => emit(const ChatError('Failed to send message')),
        (message) {
          final updated = <Message>[...currentMessages, message];
          emit(MessagesLoaded(
            conversationId: event.conversationId,
            messages: updated,
          ));
        },
      );
    });
  }
}
