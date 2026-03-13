import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Comment>>> getComments(
      String highlightId) async {
    try {
      final result = await remoteDataSource.getComments(highlightId);
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required String highlightId,
    required String userId,
    required String username,
    required String? profileImage,
    required String text,
  }) async {
    try {
      final result = await remoteDataSource.addComment(
        highlightId: highlightId,
        userId: userId,
        username: username,
        profileImage: profileImage,
        text: text,
      );
      return Right(result);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
