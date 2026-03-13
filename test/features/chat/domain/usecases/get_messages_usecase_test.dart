import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/chat/domain/entities/message.dart';
import 'package:goal_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:goal_connect/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late GetMessagesUsecase usecase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    usecase = GetMessagesUsecase(mockRepository);
  });

  const tConversationId = 'conv_1';
  final tMessages = [
    Message(
      id: 'msg_1',
      conversationId: tConversationId,
      senderId: 'user_1',
      senderName: 'Yafet',
      text: 'Hello!',
      createdAt: DateTime(2026, 1, 1, 10, 0),
    ),
    Message(
      id: 'msg_2',
      conversationId: tConversationId,
      senderId: 'scout_1',
      senderName: 'Scout',
      text: 'Great highlight!',
      createdAt: DateTime(2026, 1, 1, 10, 5),
      isRead: true,
    ),
  ];

  test('should return list of messages on success', () async {
    when(() => mockRepository.getMessages(any()))
        .thenAnswer((_) async => Right(tMessages));

    final result = await usecase(tConversationId);

    expect(result, Right(tMessages));
    verify(() => mockRepository.getMessages(tConversationId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.getMessages(any()))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(tConversationId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
    verify(() => mockRepository.getMessages(tConversationId)).called(1);
  });

  test('should return empty list for conversation with no messages', () async {
    when(() => mockRepository.getMessages(any()))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase(tConversationId);

    expect(result, const Right(<Message>[]));
    verify(() => mockRepository.getMessages(tConversationId)).called(1);
  });
}
