import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/player_profile_repository.dart';

class SavePlayerUsecase {
  final PlayerProfileRepository repository;

  SavePlayerUsecase(this.repository);

  Future<Either<Failure, void>> call({required String playerId}) {
    return repository.savePlayer(playerId: playerId);
  }
}
