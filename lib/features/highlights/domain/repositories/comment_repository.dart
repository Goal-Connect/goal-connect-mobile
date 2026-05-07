import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/comment.dart';
import '../entities/toggle_like_result.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(String highlightId);

  Future<Either<Failure, Comment>> addComment({
    required String highlightId,
    required String text,
    String? parentCommentId,
  });

  Future<Either<Failure, void>> deleteComment({
    required String highlightId,
    required String commentId,
  });

  Future<Either<Failure, CommentLikeToggleResult>> toggleCommentLike({
    required String highlightId,
    required String commentId,
  });
}
