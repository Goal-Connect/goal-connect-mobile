import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/player_profile.dart';
import '../entities/players_list_result.dart';

abstract class PlayerProfileRepository {
  Future<Either<Failure, PlayerProfile>> getPlayerProfile({
    required String playerId,
  });

  Future<Either<Failure, bool>> toggleFollow({
    required String playerId,
  });

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
  });

  Future<Either<Failure, List<PlayerProfile>>> getSavedPlayers();

  Future<Either<Failure, void>> savePlayer({required String playerId});

  Future<Either<Failure, void>> unsavePlayer({required String playerId});
}
