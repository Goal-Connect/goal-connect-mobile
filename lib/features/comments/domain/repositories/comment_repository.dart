import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(String highlightId);
  Future<Either<Failure, Comment>> addComment({
    required String highlightId,
    required String userId,
    required String username,
    required String? profileImage,
    required String text,
  });
  Future<Either<Failure, void>> deleteComment(String commentId);
}
