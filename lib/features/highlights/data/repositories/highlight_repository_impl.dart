import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/repositories/highlight_repository.dart';
import '../datasources/highlight_remote_datasource.dart';

class HighlightRepositoryImpl implements HighlightRepository {
  final HighlightRemoteDataSource remoteDataSource;

  HighlightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Highlight>> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  }) async {
    try {
      final result = await remoteDataSource.uploadHighlight(
        playerId: playerId,
        videoPath: videoPath,
        caption: caption,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteHighlight({
    required String highlightId,
  }) async {
    try {
      await remoteDataSource.deleteHighlight(highlightId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Highlight>>> getHighlightsFeed() async {
    try {
      final result = await remoteDataSource.getHighlightsFeed();

      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Highlight>>> getPlayerHighlights({
    required String playerId,
  }) async {
    try {
      final result = await remoteDataSource.getPlayerHighlights(playerId);

      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
