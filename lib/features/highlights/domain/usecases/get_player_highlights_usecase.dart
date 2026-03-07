import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';
import '../repositories/highlight_repository.dart';

class GetPlayerHighlightsUsecase {
  final HighlightRepository repository;

  GetPlayerHighlightsUsecase(this.repository);

  Future<Either<Failure, List<Highlight>>> call({required String playerId}) {
    return repository.getPlayerHighlights(playerId: playerId);
  }
}
