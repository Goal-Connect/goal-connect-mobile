import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/chat/domain/entities/conversation.dart';
import 'package:goal_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:goal_connect/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late GetConversationsUsecase usecase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    usecase = GetConversationsUsecase(mockRepository);
  });

  final tUserId = 'user_1';
  final tConversations = [
    Conversation(
      id: 'conv_1',
      participantId: 'p1',
      participantName: 'Player One',
      participantRole: 'player',
      lastMessage: 'Hello!',
      updatedAt: DateTime(2026, 1, 1),
    ),
    Conversation(
      id: 'conv_2',
      participantId: 'p2',
      participantName: 'Scout Two',
      participantRole: 'scout',
      lastMessage: 'Good game!',
      updatedAt: DateTime(2026, 1, 2),
      unreadCount: 3,
    ),
  ];

  test('should return list of conversations on success', () async {
    when(() => mockRepository.getConversations(any()))
        .thenAnswer((_) async => Right(tConversations));

    final result = await usecase(tUserId);

    expect(result, Right(tConversations));
    verify(() => mockRepository.getConversations(tUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.getConversations(any()))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(tUserId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
    verify(() => mockRepository.getConversations(tUserId)).called(1);
  });

  test('should return empty list when no conversations exist', () async {
    when(() => mockRepository.getConversations(any()))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase(tUserId);

    expect(result, const Right(<Conversation>[]));
    verify(() => mockRepository.getConversations(tUserId)).called(1);
  });
}
