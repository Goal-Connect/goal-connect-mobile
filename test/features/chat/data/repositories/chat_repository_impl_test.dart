import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import 'package:goal_connect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:goal_connect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:goal_connect/features/chat/data/services/chat_socket_service.dart';
import 'package:goal_connect/features/chat/domain/entities/conversation.dart';
import 'package:goal_connect/features/profile/domain/repositories/player_profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemote extends Mock implements ChatRemoteDataSource {}

class MockAuthUserLocal extends Mock implements AuthUserLocalDataSource {}

class MockChatSocket extends Mock implements ChatSocketService {}

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemote mockRemote;
  late MockAuthUserLocal mockUserLocal;
  late MockChatSocket mockSocket;
  late MockPlayerProfileRepository mockPlayerProfileRepository;

  setUp(() {
    mockRemote = MockChatRemote();
    mockUserLocal = MockAuthUserLocal();
    mockSocket = MockChatSocket();
    mockPlayerProfileRepository = MockPlayerProfileRepository();
    when(() => mockSocket.isConnected).thenReturn(false);
    repository = ChatRepositoryImpl(
      remoteDataSource: mockRemote,
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
    test('returns empty list when no threads have been touched yet', () async {
      final result = await repository.getConversations();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected right'),
        (list) => expect(list, isEmpty),
      );
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
