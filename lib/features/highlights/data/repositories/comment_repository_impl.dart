import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/toggle_like_result.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  final AuthUserLocalDataSource userCache;

  CommentRepositoryImpl({
    required this.remoteDataSource,
    required this.userCache,
  });

  Future<String?> _currentUserId() async {
    final u = await userCache.readCachedUser();
    return u?.id;
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(String highlightId) async {
    try {
      final uid = await _currentUserId();
      final result = await remoteDataSource.getComments(
        highlightId,
        currentUserId: uid,
      );
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required String highlightId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final result = await remoteDataSource.addComment(
        videoId: highlightId,
        text: text,
        parentCommentId: parentCommentId,
      );
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String highlightId,
    required String commentId,
  }) async {
    try {
      await remoteDataSource.deleteComment(
        videoId: highlightId,
        commentId: commentId,
      );
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CommentLikeToggleResult>> toggleCommentLike({
    required String highlightId,
    required String commentId,
  }) async {
    try {
      final result = await remoteDataSource.toggleCommentLike(
        videoId: highlightId,
        commentId: commentId,
      );
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
