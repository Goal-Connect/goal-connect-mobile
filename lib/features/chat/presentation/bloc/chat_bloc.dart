import 'dart:async';
import 'dart:developer' as developer;

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

void _log(String msg, [Object? data]) {
  developer.log(data == null ? msg : '$msg $data', name: 'chat.bloc');
}

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
    on<ChatSocketMessageEditedEvent>(_onSocketEdited);
    on<ChatSocketMessageDeletedEvent>(_onSocketDeleted);
    on<ChatSocketTypingStartEvent>(_onTypingStart);
    on<ChatSocketTypingStopEvent>(_onTypingStop);
    on<ChatSocketMessagesReadEvent>(_onMessagesRead);
    on<TypingNotifiedEvent>(_onTypingNotified);
    on<MarkConversationReadEvent>(_onMarkRead);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);

    _socketSub = _socket.onMessageReceived.listen((raw) {
      _log('rx message:received', raw);
      add(ChatSocketMessageReceivedEvent(raw));
    });
    _sentSub = _socket.onMessageSent.listen((raw) {
      _log('rx message:sent', raw);
      add(ChatSocketMessageReceivedEvent(raw));
    });
    _editedSub = _socket.onMessageEdited.listen((raw) {
      _log('rx message:edited', raw);
      add(ChatSocketMessageEditedEvent(raw));
    });
    _deletedSub = _socket.onMessageDeleted.listen((raw) {
      final id = (raw['_id'] ?? raw['id'])?.toString();
      _log('rx message:deleted', id);
      if (id != null && id.isNotEmpty) {
        add(ChatSocketMessageDeletedEvent(id));
      }
    });
    _typingStartSub = _socket.onTypingStart.listen((id) {
      _log('rx typing:start', id);
      add(ChatSocketTypingStartEvent(id));
    });
    _typingStopSub = _socket.onTypingStop.listen((id) {
      _log('rx typing:stop', id);
      add(ChatSocketTypingStopEvent(id));
    });
    _readSub = _socket.onMessagesRead.listen((p) {
      _log('rx message:read', {'by': p.by, 'count': p.messageIds.length});
      add(ChatSocketMessagesReadEvent(messageIds: p.messageIds, by: p.by));
    });
  }

  final GetConversationsUsecase getConversations;
  final GetMessagesUsecase getMessages;
  final SendMessageUsecase sendMessage;
  final GetCachedUserUsecase getCachedUser;
  final ChatRepository _repository;
  final ChatSocketService _socket;

  StreamSubscription<Map<String, dynamic>>? _socketSub;
  StreamSubscription<Map<String, dynamic>>? _sentSub;
  StreamSubscription<Map<String, dynamic>>? _editedSub;
  StreamSubscription<Map<String, dynamic>>? _deletedSub;
  StreamSubscription<String>? _typingStartSub;
  StreamSubscription<String>? _typingStopSub;
  StreamSubscription<MessagesReadPayload>? _readSub;

  /// Debounce: send `typing:stop` after the user stops typing for ~3s.
  Timer? _typingStopTimer;
  bool _typingNotified = false;
  String? _typingPeerId;

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
    // Show the loading spinner immediately so the chat list page (which is
    // still mounted under the conversation page) doesn't render its empty
    // state for the brief window before the refresh completes.
    emit(ChatLoading());
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
    _log('SEND tapped', {
      'peerId': event.peerThread.id,
      'peerName': event.peerThread.participantName,
      'len': event.text.length,
      'preview': event.text.length > 40
          ? '${event.text.substring(0, 40)}…'
          : event.text,
      'socketConnected': _socket.isConnected,
    });
    final current = state;
    // Allow sending even if message history failed to load
    List<Message> currentMessages = <Message>[];
    if (current is MessagesLoaded) {
      currentMessages = current.messages;
    } else if (current is MessageSending) {
      currentMessages = current.messages;
    }

    emit(MessageSending(
      conversationId: event.peerThread.id,
      messages: List<Message>.from(currentMessages),
    ));

    final result = await sendMessage(
      peerThread: event.peerThread,
      text: event.text,
    );

    result.fold(
      (failure) {
        _log('SEND failed', {
          'peerId': event.peerThread.id,
          'reason': failure is ChatFailure ? failure.message : 'unknown',
        });
        emit(ChatError(
          failure is ChatFailure ? failure.message : 'Failed to send message',
        ));
      },
      (message) {
        _log('SEND ok', {
          'peerId': event.peerThread.id,
          'msgId': message.id,
          'isPending': message.id.startsWith('pending_'),
        });
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
    final cached = await getCachedUser();
    if (cached == null) return;
    final user = cached.user;

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
      return;
    }

    // Receiver is anywhere outside the matching thread (chat list, initial,
    // a different conversation): refresh the conversation list so the new /
    // touched thread surfaces immediately.
    final refreshed = await getConversations();
    refreshed.fold(
      (_) {},
      (conversations) {
        if (cur is! MessagesLoaded) {
          emit(ConversationsLoaded(conversations));
        }
      },
    );
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

  Future<void> _onSocketEdited(
    ChatSocketMessageEditedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final cur = state;
    if (cur is! MessagesLoaded) return;
    final raw = event.raw;
    final id = (raw['_id'] ?? raw['id'])?.toString();
    final newContent = (raw['content'] ?? raw['text'])?.toString();
    if (id == null || id.isEmpty || newContent == null) return;
    final next = cur.messages
        .map((m) => m.id == id ? m.copyWith(text: newContent, edited: true) : m)
        .toList();
    emit(MessagesLoaded(conversationId: cur.conversationId, messages: next));
  }

  Future<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    _log('edit message', {'id': event.messageId, 'len': event.newContent.length});
    final cur = state;
    if (cur is MessagesLoaded) {
      // Optimistic: update locally so the bubble reflects the new text right
      // away. The server's `message:edited` echo will reconcile the canonical
      // value (and confirm `edited: true`).
      final next = cur.messages
          .map((m) => m.id == event.messageId
              ? m.copyWith(text: event.newContent, edited: true)
              : m)
          .toList();
      emit(cur.copyWith(messages: next));
    }
    _socket.emitEdit(messageId: event.messageId, newContent: event.newContent);
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    _log('delete message', {'id': event.messageId});
    final cur = state;
    if (cur is MessagesLoaded) {
      // Optimistic remove; server echoes `message:deleted` which is a no-op
      // once it's already gone locally.
      final next = cur.messages.where((m) => m.id != event.messageId).toList();
      emit(cur.copyWith(messages: next));
    }
    _socket.emitDelete(messageId: event.messageId);
  }

  Future<void> _onSocketDeleted(
    ChatSocketMessageDeletedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final cur = state;
    if (cur is! MessagesLoaded) return;
    final next =
        cur.messages.where((m) => m.id != event.messageId).toList();
    emit(cur.copyWith(messages: next));
  }

  Future<void> _onTypingStart(
    ChatSocketTypingStartEvent event,
    Emitter<ChatState> emit,
  ) async {
    final cur = state;
    if (cur is MessagesLoaded && cur.conversationId == event.fromUserId) {
      emit(cur.copyWith(peerTyping: true));
    }
  }

  Future<void> _onTypingStop(
    ChatSocketTypingStopEvent event,
    Emitter<ChatState> emit,
  ) async {
    final cur = state;
    if (cur is MessagesLoaded && cur.conversationId == event.fromUserId) {
      emit(cur.copyWith(peerTyping: false));
    }
  }

  Future<void> _onMessagesRead(
    ChatSocketMessagesReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    final cur = state;
    if (cur is! MessagesLoaded) return;
    final ids = event.messageIds.toSet();
    final next = cur.messages
        .map((m) =>
            !ids.contains(m.id) || m.isRead ? m : m.copyWith(isRead: true))
        .toList();
    emit(cur.copyWith(messages: next));
  }

  Future<void> _onTypingNotified(
    TypingNotifiedEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.isTyping) {
      if (!_typingNotified || _typingPeerId != event.peerUserId) {
        _socket.emitTypingStart(toUserId: event.peerUserId);
        _typingNotified = true;
        _typingPeerId = event.peerUserId;
      }
      _typingStopTimer?.cancel();
      _typingStopTimer = Timer(const Duration(seconds: 3), () {
        if (_typingPeerId != null) {
          _socket.emitTypingStop(toUserId: _typingPeerId!);
        }
        _typingNotified = false;
      });
    } else {
      _typingStopTimer?.cancel();
      if (_typingNotified) {
        _socket.emitTypingStop(toUserId: event.peerUserId);
        _typingNotified = false;
      }
    }
  }

  Future<void> _onMarkRead(
    MarkConversationReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    _log('mark read', {'peerId': event.peerUserId});
    await _socket.markRead(withUserId: event.peerUserId);
  }

  @override
  void onEvent(ChatEvent event) {
    super.onEvent(event);
    _log('event → ${event.runtimeType}');
  }

  @override
  void onTransition(Transition<ChatEvent, ChatState> transition) {
    super.onTransition(transition);
    _log('state ${transition.currentState.runtimeType} → '
        '${transition.nextState.runtimeType}',
        {'on': transition.event.runtimeType.toString()});
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _sentSub?.cancel();
    _editedSub?.cancel();
    _deletedSub?.cancel();
    _typingStartSub?.cancel();
    _typingStopSub?.cancel();
    _readSub?.cancel();
    _typingStopTimer?.cancel();
    return super.close();
  }
}
