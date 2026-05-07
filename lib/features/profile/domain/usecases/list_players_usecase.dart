import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/players_list_result.dart';
import '../repositories/player_profile_repository.dart';

class ListPlayersUsecase {
  final PlayerProfileRepository repository;
  ListPlayersUsecase(this.repository);

  Future<Either<Failure, PlayersListResult>> call({
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
  }) {
    return repository.listPlayers(
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
  }
}
