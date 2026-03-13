import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';

abstract class HighlightRepository {
  Future<Either<Failure, Highlight>> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  });

  Future<Either<Failure, void>> deleteHighlight({required String highlightId});

  Future<Either<Failure, List<Highlight>>> getHighlightsFeed();

  Future<Either<Failure, List<Highlight>>> getPlayerHighlights({
    required String playerId,
  });

  Future<Either<Failure, bool>> toggleLike({required String highlightId});
}
