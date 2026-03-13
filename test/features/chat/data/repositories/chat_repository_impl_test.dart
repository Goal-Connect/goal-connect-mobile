import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:goal_connect/features/chat/data/models/conversation_model.dart';
import 'package:goal_connect/features/chat/data/models/message_model.dart';
import 'package:goal_connect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('getConversations', () {
    const tUserId = 'user_1';
    final tConversationModels = [
      ConversationModel(
        id: 'conv_1',
        participantId: 'p1',
        participantName: 'Player One',
        participantRole: 'player',
        lastMessage: 'Hello!',
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];

    test('should return Right with conversations when datasource succeeds',
        () async {
      when(() => mockDataSource.getConversations(any()))
          .thenAnswer((_) async => tConversationModels);

      final result = await repository.getConversations(tUserId);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (conversations) => expect(conversations, tConversationModels),
      );
      verify(() => mockDataSource.getConversations(tUserId)).called(1);
    });

    test('should return Left(ServerFailure) when datasource throws', () async {
      when(() => mockDataSource.getConversations(any()))
          .thenThrow(Exception('Server error'));

      final result = await repository.getConversations(tUserId);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getMessages', () {
    const tConversationId = 'conv_1';
    final tMessageModels = [
      MessageModel(
        id: 'msg_1',
        conversationId: tConversationId,
        senderId: 'user_1',
        senderName: 'Yafet',
        text: 'Hello!',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    test('should return Right with messages when datasource succeeds',
        () async {
      when(() => mockDataSource.getMessages(any()))
          .thenAnswer((_) async => tMessageModels);

      final result = await repository.getMessages(tConversationId);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (messages) => expect(messages, tMessageModels),
      );
      verify(() => mockDataSource.getMessages(tConversationId)).called(1);
    });

    test('should return Left(ServerFailure) when datasource throws', () async {
      when(() => mockDataSource.getMessages(any()))
          .thenThrow(Exception('Server error'));

      final result = await repository.getMessages(tConversationId);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('sendMessage', () {
    final tMessageModel = MessageModel(
      id: 'msg_new',
      conversationId: 'conv_1',
      senderId: 'user_1',
      senderName: 'Yafet',
      text: 'Test message',
      createdAt: DateTime(2026, 3, 13),
    );

    test('should return Right with message when datasource succeeds',
        () async {
      when(() => mockDataSource.sendMessage(
            conversationId: any(named: 'conversationId'),
            senderId: any(named: 'senderId'),
            senderName: any(named: 'senderName'),
            text: any(named: 'text'),
          )).thenAnswer((_) async => tMessageModel);

      final result = await repository.sendMessage(
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Yafet',
        text: 'Test message',
      );

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (message) => expect(message, tMessageModel),
      );
    });

    test('should return Left(ServerFailure) when datasource throws', () async {
      when(() => mockDataSource.sendMessage(
            conversationId: any(named: 'conversationId'),
            senderId: any(named: 'senderId'),
            senderName: any(named: 'senderName'),
            text: any(named: 'text'),
          )).thenThrow(Exception('Network error'));

      final result = await repository.sendMessage(
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Yafet',
        text: 'Test message',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
