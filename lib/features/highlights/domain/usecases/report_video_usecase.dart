import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../repositories/report_repository.dart';

class ReportVideoUsecase {
  final ReportRepository repository;

  ReportVideoUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String targetId,
    required String description,
  }) {
    return repository.reportVideo(
      targetId: targetId,
      description: description,
    );
  }
}
