import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUsecase {
  final ChatRepository repository;
  GetMessagesUsecase(this.repository);

  Future<Either<Failure, List<Message>>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}
