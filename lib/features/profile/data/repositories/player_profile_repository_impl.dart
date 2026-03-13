import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/repositories/player_profile_repository.dart';
import '../datasources/player_profile_remote_datasource.dart';

class PlayerProfileRepositoryImpl implements PlayerProfileRepository {
  final PlayerProfileRemoteDataSource remoteDataSource;

  PlayerProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PlayerProfile>> getPlayerProfile({
    required String playerId,
  }) async {
    try {
      final result = await remoteDataSource.getPlayerProfile(playerId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFollow({
    required String playerId,
  }) async {
    try {
      final result = await remoteDataSource.toggleFollow(playerId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
