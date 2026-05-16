import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';

class PlayerSearchFilters extends Equatable {
  final String? position;
  final String? strongFoot;
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final int? maxHeight;

  const PlayerSearchFilters({
    this.position,
    this.strongFoot,
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
  });

  static const empty = PlayerSearchFilters();

  bool get isActive =>
      (position != null && position!.isNotEmpty) ||
      (strongFoot != null && strongFoot!.isNotEmpty) ||
      minAge != null ||
      maxAge != null ||
      minHeight != null ||
      maxHeight != null;

  int get activeCount => [
        position,
        strongFoot,
        minAge,
        maxAge,
        minHeight,
        maxHeight,
      ].where((v) => v != null && (v is! String || v.isNotEmpty)).length;

  @override
  List<Object?> get props =>
      [position, strongFoot, minAge, maxAge, minHeight, maxHeight];
}

class PlayerSearchState extends Equatable {
  final List<PlayerProfile> featuredPlayers;
  final List<PlayerProfile> searchResults;
  final String query;
  final PlayerSearchFilters filters;
  final bool loadingFeatured;
  final bool loadingSearch;
  final bool loadingMore;
  final String? errorMessage;
  final int searchPage;
  final int searchTotalPages;

  const PlayerSearchState({
    this.featuredPlayers = const [],
    this.searchResults = const [],
    this.query = '',
    this.filters = PlayerSearchFilters.empty,
    this.loadingFeatured = false,
    this.loadingSearch = false,
    this.loadingMore = false,
    this.errorMessage,
    this.searchPage = 0,
    this.searchTotalPages = 1,
  });

  bool get hasActiveQueryOrFilters => query.isNotEmpty || filters.isActive;

  bool get hasMoreSearch =>
      hasActiveQueryOrFilters &&
      searchPage > 0 &&
      searchPage < searchTotalPages;

  PlayerSearchState copyWith({
    List<PlayerProfile>? featuredPlayers,
    List<PlayerProfile>? searchResults,
    String? query,
    PlayerSearchFilters? filters,
    bool? loadingFeatured,
    bool? loadingSearch,
    bool? loadingMore,
    String? errorMessage,
    int? searchPage,
    int? searchTotalPages,
    bool clearError = false,
  }) {
    return PlayerSearchState(
      featuredPlayers: featuredPlayers ?? this.featuredPlayers,
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      loadingFeatured: loadingFeatured ?? this.loadingFeatured,
      loadingSearch: loadingSearch ?? this.loadingSearch,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchPage: searchPage ?? this.searchPage,
      searchTotalPages: searchTotalPages ?? this.searchTotalPages,
    );
  }

  @override
  List<Object?> get props => [
        featuredPlayers,
        searchResults,
        query,
        filters,
        loadingFeatured,
        loadingSearch,
        loadingMore,
        errorMessage,
        searchPage,
        searchTotalPages,
      ];
}
