import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/player_profile_repository.dart';

class UnsavePlayerUsecase {
  final PlayerProfileRepository repository;

  UnsavePlayerUsecase(this.repository);

  Future<Either<Failure, void>> call({required String playerId}) {
    return repository.unsavePlayer(playerId: playerId);
  }
}
