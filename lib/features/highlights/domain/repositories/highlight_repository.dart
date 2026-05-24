import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';
import '../entities/toggle_like_result.dart';

abstract class HighlightRepository {
  Future<Either<Failure, Highlight>> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  });

  Future<Either<Failure, void>> deleteHighlight({required String highlightId});

  Future<Either<Failure, Highlight>> updateHighlight({
    required String highlightId,
    String? title,
    String? description,
    String? privacy,
    String? drillType,
  });

  Future<Either<Failure, List<Highlight>>> getHighlightsFeed({
    List<String>? positions,
    List<String>? regions,
    int? minAge,
    int? maxAge,
  });

  Future<Either<Failure, List<Highlight>>> getPlayerHighlights({
    required String playerId,
  });

  Future<Either<Failure, ToggleLikeResult>> toggleLike({
    required String highlightId,
  });
}
