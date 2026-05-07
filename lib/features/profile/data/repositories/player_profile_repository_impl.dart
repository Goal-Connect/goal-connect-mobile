import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/entities/players_list_result.dart';
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

  @override
  Future<Either<Failure, PlayersListResult>> listPlayers({
    required int page,
    required int limit,
    String? search,
    String? position,
    String? strongFoot,
    int? minAge,
    int? maxAge,
    int? minHeight,
    int? maxHeight,
    String? sortBy,
    String? sortOrder,
    String? meta,
  }) async {
    try {
      final result = await remoteDataSource.listPlayers(
        page: page,
        limit: limit,
        search: search,
        position: position,
        strongFoot: strongFoot,
        minAge: minAge,
        maxAge: maxAge,
        minHeight: minHeight,
        maxHeight: maxHeight,
        sortBy: sortBy,
        sortOrder: sortOrder,
        meta: meta,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
