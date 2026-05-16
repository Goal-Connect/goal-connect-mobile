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

/// User applied the filter sheet — re-runs the current query with new filters.
class PlayerSearchFiltersApplied extends PlayerSearchEvent {
  final String? position;
  final String? strongFoot;
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final int? maxHeight;

  const PlayerSearchFiltersApplied({
    this.position,
    this.strongFoot,
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
  });

  @override
  List<Object?> get props =>
      [position, strongFoot, minAge, maxAge, minHeight, maxHeight];
}

class PlayerSearchFiltersCleared extends PlayerSearchEvent {
  const PlayerSearchFiltersCleared();
}
