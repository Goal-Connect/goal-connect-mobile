import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/player_profile.dart';
import '../repositories/player_profile_repository.dart';

class GetSavedPlayersUsecase {
  final PlayerProfileRepository repository;

  GetSavedPlayersUsecase(this.repository);

  Future<Either<Failure, List<PlayerProfile>>> call() {
    return repository.getSavedPlayers();
  }
}
