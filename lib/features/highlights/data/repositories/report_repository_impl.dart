import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> reportVideo({
    required String targetId,
    required String description,
  }) async {
    try {
      await remoteDataSource.reportVideo(
        targetId: targetId,
        description: description,
      );
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
