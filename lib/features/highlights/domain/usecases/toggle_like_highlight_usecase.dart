import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/toggle_like_result.dart';
import '../repositories/highlight_repository.dart';

class ToggleLikeHighlightUsecase {
  final HighlightRepository repository;
  ToggleLikeHighlightUsecase(this.repository);

  Future<Either<Failure, ToggleLikeResult>> call({
    required String highlightId,
  }) {
    return repository.toggleLike(highlightId: highlightId);
  }
}
