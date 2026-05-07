import 'player_profile.dart';

/// Paginated result from `GET /api/players`.
class PlayersListResult {
  final List<PlayerProfile> players;
  final int page;
  final int pages;
  final int total;
  final int count;

  const PlayersListResult({
    required this.players,
    required this.page,
    required this.pages,
    required this.total,
    required this.count,
  });

  bool get hasNextPage => page < pages && players.isNotEmpty;
}
