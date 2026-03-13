import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class AddCommentUsecase {
  final CommentRepository repository;
  AddCommentUsecase(this.repository);

  Future<Either<Failure, Comment>> call({
    required String highlightId,
    required String userId,
    required String username,
    required String? profileImage,
    required String text,
  }) {
    return repository.addComment(
      highlightId: highlightId,
      userId: userId,
      username: username,
      profileImage: profileImage,
      text: text,
    );
  }
}
