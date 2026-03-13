import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsUsecase {
  final CommentRepository repository;
  GetCommentsUsecase(this.repository);

  Future<Either<Failure, List<Comment>>> call(String highlightId) {
    return repository.getComments(highlightId);
  }
}
