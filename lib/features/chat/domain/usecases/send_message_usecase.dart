import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repository;
  SendMessageUsecase(this.repository);

  Future<Either<Failure, Message>> call({
    required Conversation peerThread,
    required String text,
  }) {
    return repository.sendMessage(
      peerThread: peerThread,
      text: text,
    );
  }
}
