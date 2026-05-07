import 'package:equatable/equatable.dart';

abstract class PlayerSearchEvent extends Equatable {
  const PlayerSearchEvent();
  @override
  List<Object?> get props => [];
}

/// Initial horizontal strip: `GET /players` without search.
class PlayerSearchLoadFeatured extends PlayerSearchEvent {
  const PlayerSearchLoadFeatured();
}

/// Debounced search box — runs `GET /players?search=…`.
class PlayerSearchQuerySubmitted extends PlayerSearchEvent {
  final String query;
  const PlayerSearchQuerySubmitted(this.query);
  @override
  List<Object?> get props => [query];
}

class PlayerSearchLoadMore extends PlayerSearchEvent {
  const PlayerSearchLoadMore();
}
