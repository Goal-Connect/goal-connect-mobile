import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUsecase {
  final ChatRepository repository;
  GetConversationsUsecase(this.repository);

  Future<Either<Failure, List<Conversation>>> call(String userId) {
    return repository.getConversations(userId);
  }
}
