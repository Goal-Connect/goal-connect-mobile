import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:goal_connect/features/chat/domain/entities/conversation.dart';
import 'package:goal_connect/features/chat/domain/entities/message.dart';
import 'package:goal_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:goal_connect/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:goal_connect/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:goal_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:goal_connect/features/chat/data/services/chat_socket_service.dart';
import 'package:goal_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goal_connect/features/chat/presentation/bloc/chat_event.dart';
import 'package:goal_connect/features/chat/presentation/bloc/chat_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConversationsUsecase extends Mock
    implements GetConversationsUsecase {}

class MockGetMessagesUsecase extends Mock implements GetMessagesUsecase {}

class MockSendMessageUsecase extends Mock implements SendMessageUsecase {}

class MockGetCachedUserUsecase extends Mock implements GetCachedUserUsecase {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockChatSocketService extends Mock implements ChatSocketService {}

void main() {
  late MockGetConversationsUsecase mockGetConversations;
  late MockGetMessagesUsecase mockGetMessages;
  late MockSendMessageUsecase mockSendMessage;
  late MockGetCachedUserUsecase mockGetCachedUser;
  late MockChatRepository mockRepo;
  late MockChatSocketService mockSocket;

  setUp(() {
    mockGetConversations = MockGetConversationsUsecase();
    mockGetMessages = MockGetMessagesUsecase();
    mockSendMessage = MockSendMessageUsecase();
    mockGetCachedUser = MockGetCachedUserUsecase();
    mockRepo = MockChatRepository();
    mockSocket = MockChatSocketService();
    when(() => mockSocket.onMessageReceived)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onMessageSent)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onMessageEdited)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onMessageDeleted)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onTypingStart)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onTypingStop)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.onMessagesRead)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.isConnected).thenReturn(false);
  });

  ChatBloc buildBloc() => ChatBloc(
        getConversations: mockGetConversations,
        getMessages: mockGetMessages,
        sendMessage: mockSendMessage,
        getCachedUser: mockGetCachedUser,
        chatRepository: mockRepo,
        socketService: mockSocket,
      );

  final tConversations = [
    Conversation(
      id: 'conv_1',
      participantId: 'p1',
      participantName: 'Player One',
      participantRole: 'player',
      lastMessage: 'Hello!',
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  final tThread = tConversations.first;

  final tMessages = [
    Message(
      id: 'msg_1',
      conversationId: 'conv_1',
      senderId: 'user_1',
      senderName: 'Yafet',
      text: 'Hello!',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  final tSentMessage = Message(
    id: 'msg_new',
    conversationId: 'conv_1',
    senderId: 'user_1',
    senderName: 'Yafet',
    text: 'New message',
    createdAt: DateTime(2026, 3, 13),
  );

  setUpAll(() {
    registerFallbackValue(tThread);
  });

  group('GetConversationsEvent', () {
    test('emits [ChatLoading, ConversationsLoaded] on success', () async {
      when(() => mockGetConversations()).thenAnswer((_) async => Right(tConversations));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetConversationsEvent());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<ChatLoading>(), isA<ConversationsLoaded>()]);
      expect(
        (states[1] as ConversationsLoaded).conversations,
        tConversations,
      );

      await sub.cancel();
      await bloc.close();
    });

    test('emits [ChatLoading, ChatError] on failure', () async {
      when(() => mockGetConversations()).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetConversationsEvent());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<ChatLoading>(), isA<ChatError>()]);
      expect(
        (states[1] as ChatError).message,
        'Failed to load conversations',
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  group('GetMessagesEvent', () {
    test('emits [ChatLoading, MessagesLoaded] on success', () async {
      when(() => mockGetMessages(any()))
          .thenAnswer((_) async => Right(tMessages));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetMessagesEvent('conv_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<ChatLoading>(), isA<MessagesLoaded>()]);
      final loaded = states[1] as MessagesLoaded;
      expect(loaded.conversationId, 'conv_1');
      expect(loaded.messages, tMessages);

      await sub.cancel();
      await bloc.close();
    });

    test('emits [ChatLoading, ChatError] on failure', () async {
      when(() => mockGetMessages(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetMessagesEvent('conv_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<ChatLoading>(), isA<ChatError>()]);
      expect(
        (states[1] as ChatError).message,
        'Failed to load messages',
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  group('SendMessageEvent', () {
    test(
        'emits [MessageSending, MessagesLoaded] on success from initial state',
        () async {
      when(() => mockSendMessage(
            peerThread: any(named: 'peerThread'),
            text: any(named: 'text'),
          )).thenAnswer((_) async => Right(tSentMessage));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(SendMessageEvent(
        peerThread: tThread,
        text: 'New message',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<MessageSending>(), isA<MessagesLoaded>()]);
      final loaded = states[1] as MessagesLoaded;
      expect(loaded.messages, contains(tSentMessage));

      await sub.cancel();
      await bloc.close();
    });

    test('emits [MessageSending, ChatError] on send failure', () async {
      when(() => mockSendMessage(
            peerThread: any(named: 'peerThread'),
            text: any(named: 'text'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(SendMessageEvent(
        peerThread: tThread,
        text: 'Will fail',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<MessageSending>(), isA<ChatError>()]);
      expect(
        (states[1] as ChatError).message,
        'Failed to send message',
      );

      await sub.cancel();
      await bloc.close();
    });

    test('preserves existing messages when sending from MessagesLoaded state',
        () async {
      when(() => mockGetMessages(any()))
          .thenAnswer((_) async => Right(tMessages));
      when(() => mockSendMessage(
            peerThread: any(named: 'peerThread'),
            text: any(named: 'text'),
          )).thenAnswer((_) async => Right(tSentMessage));

      final bloc = buildBloc();
      final states = <ChatState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetMessagesEvent('conv_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      states.clear();

      bloc.add(SendMessageEvent(
        peerThread: tThread,
        text: 'New message',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<MessageSending>(), isA<MessagesLoaded>()]);
      final sending = states[0] as MessageSending;
      expect(sending.messages, tMessages);
      final loaded = states[1] as MessagesLoaded;
      expect(loaded.messages.length, tMessages.length + 1);
      expect(loaded.messages.last, tSentMessage);

      await sub.cancel();
      await bloc.close();
    });
  });
}
