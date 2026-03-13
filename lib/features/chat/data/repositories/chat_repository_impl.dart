import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
      String userId) async {
    try {
      final result = await remoteDataSource.getConversations(userId);
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
      String conversationId) async {
    try {
      final result = await remoteDataSource.getMessages(conversationId);
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final result = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        text: text,
      );
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
