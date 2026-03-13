import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/highlight_repository.dart';

class ToggleLikeHighlightUsecase {
  final HighlightRepository repository;
  ToggleLikeHighlightUsecase(this.repository);

  Future<Either<Failure, bool>> call({required String highlightId}) {
    return repository.toggleLike(highlightId: highlightId);
  }
}
