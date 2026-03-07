import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/highlight.dart';
import '../repositories/highlight_repository.dart';

class UploadHighlightUsecase {
  final HighlightRepository repository;

  UploadHighlightUsecase(this.repository);

  Future<Either<Failure, Highlight>> call({
    required String playerId,
    required String videoPath,
    required String caption,
  }) {
    return repository.uploadHighlight(
      playerId: playerId,
      videoPath: videoPath,
      caption: caption,
    );
  }
}
