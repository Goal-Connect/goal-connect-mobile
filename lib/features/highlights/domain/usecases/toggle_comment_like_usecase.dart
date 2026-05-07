import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/toggle_like_result.dart';
import '../repositories/comment_repository.dart';

class ToggleCommentLikeUsecase {
  final CommentRepository repository;
  ToggleCommentLikeUsecase(this.repository);

  Future<Either<Failure, CommentLikeToggleResult>> call({
    required String highlightId,
    required String commentId,
  }) {
    return repository.toggleCommentLike(
      highlightId: highlightId,
      commentId: commentId,
    );
  }
}
