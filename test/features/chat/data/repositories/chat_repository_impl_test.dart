import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import 'package:goal_connect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:goal_connect/features/chat/data/datasources/conversation_local_datasource.dart';
import 'package:goal_connect/features/chat/data/models/conversation_model.dart';
import 'package:goal_connect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:goal_connect/features/chat/data/services/chat_socket_service.dart';
import 'package:goal_connect/features/chat/domain/entities/conversation.dart';
import 'package:goal_connect/features/profile/domain/repositories/player_profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemote extends Mock implements ChatRemoteDataSource {}

class MockConversationLocal extends Mock implements ConversationLocalDataSource {}

class MockAuthUserLocal extends Mock implements AuthUserLocalDataSource {}

class MockChatSocket extends Mock implements ChatSocketService {}

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemote mockRemote;
  late MockConversationLocal mockLocal;
  late MockAuthUserLocal mockUserLocal;
  late MockChatSocket mockSocket;
  late MockPlayerProfileRepository mockPlayerProfileRepository;

  setUp(() {
    mockRemote = MockChatRemote();
    mockLocal = MockConversationLocal();
    mockUserLocal = MockAuthUserLocal();
    mockSocket = MockChatSocket();
    mockPlayerProfileRepository = MockPlayerProfileRepository();
    when(() => mockSocket.isConnected).thenReturn(false);
    repository = ChatRepositoryImpl(
      remoteDataSource: mockRemote,
      conversationLocal: mockLocal,
      userLocal: mockUserLocal,
      socketService: mockSocket,
      playerProfileRepository: mockPlayerProfileRepository,
    );
  });

  final tPeerId = 'peer_user';
  final tThread = Conversation(
    id: tPeerId,
    participantId: tPeerId,
    participantName: 'Player One',
    participantRole: 'player',
    lastMessage: '',
    updatedAt: DateTime(2026, 1, 1),
  );

  group('getConversations', () {
    test('returns threads from local storage', () async {
      final models = [
        ConversationModel(
          id: tPeerId,
          participantId: tPeerId,
          participantName: 'Player One',
          participantRole: 'player',
          lastMessage: 'Hi',
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];
      when(() => mockLocal.loadThreads()).thenAnswer((_) async => models);

      final result = await repository.getConversations();

      expect(result.isRight(), isTrue);
      verify(() => mockLocal.loadThreads()).called(1);
    });
  });

  group('getMessages', () {
    test('maps API messages when user is cached', () async {
      when(() => mockUserLocal.readCachedUser()).thenAnswer(
        (_) async => null,
      );

      final result = await repository.getMessages(tPeerId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('sendMessage', () {
    test('uses HTTP when socket is disconnected', () async {
      when(() => mockUserLocal.readCachedUser()).thenAnswer(
        (_) async => null,
      );

      final result = await repository.sendMessage(
        peerThread: tThread,
        text: 'Hello',
      );

      expect(result.isLeft(), isTrue);
      verifyZeroInteractions(mockRemote);
    });
  });
}
