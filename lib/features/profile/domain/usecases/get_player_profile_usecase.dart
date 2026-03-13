import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/player_profile.dart';
import '../repositories/player_profile_repository.dart';

class GetPlayerProfileUsecase {
  final PlayerProfileRepository repository;

  GetPlayerProfileUsecase(this.repository);

  Future<Either<Failure, PlayerProfile>> call({required String playerId}) {
    return repository.getPlayerProfile(playerId: playerId);
  }
}
