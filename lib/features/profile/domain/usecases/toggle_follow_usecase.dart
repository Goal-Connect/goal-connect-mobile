import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/player_profile_repository.dart';

class ToggleFollowUsecase {
  final PlayerProfileRepository repository;

  ToggleFollowUsecase(this.repository);

  Future<Either<Failure, bool>> call({required String playerId}) {
    return repository.toggleFollow(playerId: playerId);
  }
}
