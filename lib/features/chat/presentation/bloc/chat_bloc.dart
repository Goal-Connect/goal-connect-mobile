import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/fialures.dart';
import '../../../auth/domain/usecases/get_cached_user_usecase.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../data/services/chat_socket_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required this.getConversations,
    required this.getMessages,
    required this.sendMessage,
    required this.getCachedUser,
    required ChatRepository chatRepository,
    required ChatSocketService socketService,
  })  : _repository = chatRepository,
        _socket = socketService,
        super(ChatInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<LeaveConversationEvent>(_onLeaveConversation);
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ChatSocketMessageReceivedEvent>(_onSocketMessage);

    _socketSub = _socket.onMessageReceived.listen(
      (raw) => add(ChatSocketMessageReceivedEvent(raw)),
    );
  }

  final GetConversationsUsecase getConversations;
  final GetMessagesUsecase getMessages;
  final SendMessageUsecase sendMessage;
  final GetCachedUserUsecase getCachedUser;
  final ChatRepository _repository;
  final ChatSocketService _socket;

  StreamSubscription<Map<String, dynamic>>? _socketSub;

  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getConversations();
    result.fold(
      (failure) => emit(const ChatError('Failed to load conversations')),
      (conversations) => emit(ConversationsLoaded(conversations)),
    );
  }

  Future<void> _onLeaveConversation(
    LeaveConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await getConversations();
    result.fold(
      (failure) => emit(const ChatError('Failed to load conversations')),
      (conversations) => emit(ConversationsLoaded(conversations)),
    );
  }

  Future<void> _onGetMessages(
    GetMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getMessages(event.conversationId);
    result.fold(
      (failure) => emit(ChatError(
        failure is ChatFailure ? failure.message : 'Failed to load messages',
      )),
      (messages) => emit(
        MessagesLoaded(
          conversationId: event.conversationId,
          messages: messages,
        ),
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    final currentMessages =
        current is MessagesLoaded ? current.messages : <Message>[];

    emit(MessageSending(
      conversationId: event.peerThread.id,
      messages: List<Message>.from(currentMessages),
    ));

    final result = await sendMessage(
      peerThread: event.peerThread,
      text: event.text,
    );

    result.fold(
      (failure) => emit(ChatError(
        failure is ChatFailure ? failure.message : 'Failed to send message',
      )),
      (message) {
        final updated = _mergeSent(currentMessages, message);
        emit(MessagesLoaded(
          conversationId: event.peerThread.id,
          messages: updated,
        ));
      },
    );
  }

  List<Message> _mergeSent(List<Message> current, Message sent) {
    final next = List<Message>.from(current);
    next.removeWhere(
      (m) =>
          m.id.startsWith('pending_') &&
          m.senderId == sent.senderId &&
          m.text == sent.text,
    );
    if (!next.any((m) => m.id == sent.id)) {
      next.add(sent);
    }
    next.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return next;
  }

  Future<void> _onSocketMessage(
    ChatSocketMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final user = await getCachedUser();
    if (user == null) return;

    final raw = event.raw;
    final myId = user.id;
    final s = raw['senderId']?.toString() ?? '';
    final r = raw['receiverId']?.toString() ?? '';
    final peerUserId = s == myId ? r : (r == myId ? s : s);
    if (peerUserId.isEmpty) return;

    final peerName = await _repository.resolvePeerDisplayName(peerUserId);
    final msg = _repository.messageFromSocketPayload(
      raw,
      currentUserId: myId,
      selfDisplayName: user.username,
      peerDisplayName: peerName,
      peerUserId: peerUserId,
    );
    if (msg == null) return;

    await _repository.touchThreadFromIncomingMessage(msg, myId);

    final cur = state;
    if (cur is MessagesLoaded && cur.conversationId == peerUserId) {
      final merged = _mergeIncoming(cur.messages, msg, myId);
      emit(MessagesLoaded(conversationId: peerUserId, messages: merged));
    }
  }

  List<Message> _mergeIncoming(
    List<Message> current,
    Message incoming,
    String myId,
  ) {
    if (current.any((m) => m.id == incoming.id)) return current;
    final next = List<Message>.from(current);
    if (incoming.senderId == myId) {
      next.removeWhere(
        (m) => m.id.startsWith('pending_') && m.text == incoming.text,
      );
    }
    next.add(incoming);
    next.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return next;
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }
}
