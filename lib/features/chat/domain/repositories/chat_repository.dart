import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  });
}
