import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/comment_repository.dart';

class DeleteCommentUsecase {
  final CommentRepository repository;
  DeleteCommentUsecase(this.repository);

  Future<Either<Failure, void>> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
