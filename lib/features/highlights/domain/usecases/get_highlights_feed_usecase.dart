import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';
import '../repositories/highlight_repository.dart';

class GetHighlightsFeedUsecase {
  final HighlightRepository repository;

  GetHighlightsFeedUsecase(this.repository);

  Future<Either<Failure, List<Highlight>>> call() {
    return repository.getHighlightsFeed();
  }
}
