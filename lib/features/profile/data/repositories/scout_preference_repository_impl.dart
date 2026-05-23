import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../../domain/entities/scout_preference.dart';
import '../../domain/repositories/scout_preference_repository.dart';
import '../datasources/scout_preference_local_datasource.dart';
import '../datasources/scout_preference_remote_datasource.dart';
import '../models/scout_preference_model.dart';

class ScoutPreferenceRepositoryImpl implements ScoutPreferenceRepository {
  final ScoutPreferenceRemoteDataSource remoteDataSource;
  final ScoutPreferenceLocalDataSource localDataSource;

  ScoutPreferenceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ScoutPreference?>> getPreference() async {
    try {
      final remote = await remoteDataSource.getPreference();
      if (remote != null) {
        await localDataSource.write(remote);
        return Right(remote);
      }
      // Backend returned nothing (or has no GET) — drop any stale local
      // cache so the UI reflects "no preference saved".
      await localDataSource.clear();
      return const Right(null);
    } catch (_) {
      // Network/server error — fall back to whatever we have locally.
      try {
        final cached = await localDataSource.read();
        return Right(cached);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ScoutPreference>> savePreference(
    ScoutPreference preference,
  ) async {
    try {
      final model = ScoutPreferenceModel.fromEntity(preference);
      final saved = await remoteDataSource.savePreference(model);
      await localDataSource.write(saved);
      return Right(saved);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ScoutPreference>> updatePreference(
    ScoutPreference preference,
  ) async {
    try {
      final model = ScoutPreferenceModel.fromEntity(preference);
      final saved = await remoteDataSource.updatePreference(model);
      await localDataSource.write(saved);
      return Right(saved);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePreference() async {
    try {
      await remoteDataSource.deletePreference();
      await localDataSource.clear();
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
