import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/player_profile.dart';

abstract class PlayerProfileRepository {
  Future<Either<Failure, PlayerProfile>> getPlayerProfile({
    required String playerId,
  });

  Future<Either<Failure, bool>> toggleFollow({
    required String playerId,
  });
}
