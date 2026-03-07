import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/highlight_repository.dart';

class DeleteHighlightUsecase {
  final HighlightRepository repository;

  DeleteHighlightUsecase(this.repository);

  Future<Either<Failure, void>> call({required String highlightId}) {
    return repository.deleteHighlight(highlightId: highlightId);
  }
}
