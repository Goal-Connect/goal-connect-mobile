import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';

abstract class ReportRepository {
  /// Reports a highlight/video to moderation.
  ///
  /// [targetId] is the highlight id. [description] is the human-readable
  /// reason the user selected (the API expects a fixed `reason` enum so
  /// we forward the selected text through `description`).
  Future<Either<Failure, void>> reportVideo({
    required String targetId,
    required String description,
  });
}
