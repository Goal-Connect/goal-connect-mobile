import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/chat/domain/entities/conversation.dart';
import 'package:goal_connect/features/chat/domain/entities/message.dart';
import 'package:goal_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:goal_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessageUsecase usecase;
  late MockChatRepository mockRepository;

  final tThread = Conversation(
    id: 'conv_1',
    participantId: 'conv_1',
    participantName: 'Other',
    participantRole: 'player',
    lastMessage: '',
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockChatRepository();
    usecase = SendMessageUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(tThread);
  });

  final tMessage = Message(
    id: 'msg_new',
    conversationId: 'conv_1',
    senderId: 'user_1',
    senderName: 'Yafet',
    text: 'I am ready for the trial!',
    createdAt: DateTime(2026, 3, 13),
  );

  test('should return sent message on success', () async {
    when(() => mockRepository.sendMessage(
          peerThread: any(named: 'peerThread'),
          text: any(named: 'text'),
        )).thenAnswer((_) async => Right(tMessage));

    final result = await usecase(
      peerThread: tThread,
      text: 'I am ready for the trial!',
    );

    expect(result, Right(tMessage));
    verify(() => mockRepository.sendMessage(
          peerThread: tThread,
          text: 'I am ready for the trial!',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when sending fails', () async {
    when(() => mockRepository.sendMessage(
          peerThread: any(named: 'peerThread'),
          text: any(named: 'text'),
        )).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(
      peerThread: tThread,
      text: 'Hello',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
