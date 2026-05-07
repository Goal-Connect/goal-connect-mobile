import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';
import '../repositories/highlight_repository.dart';

class UpdateHighlightUsecase {
  final HighlightRepository repository;
  UpdateHighlightUsecase(this.repository);

  Future<Either<Failure, Highlight>> call({
    required String highlightId,
    String? title,
    String? description,
    String? privacy,
    String? drillType,
  }) {
    return repository.updateHighlight(
      highlightId: highlightId,
      title: title,
      description: description,
      privacy: privacy,
      drillType: drillType,
    );
  }
}
