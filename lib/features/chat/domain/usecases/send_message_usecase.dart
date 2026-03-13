import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repository;
  SendMessageUsecase(this.repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );
  }
}
