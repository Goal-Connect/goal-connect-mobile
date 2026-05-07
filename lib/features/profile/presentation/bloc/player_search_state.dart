import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';

class PlayerSearchState extends Equatable {
  final List<PlayerProfile> featuredPlayers;
  final List<PlayerProfile> searchResults;
  final String query;
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
    this.loadingFeatured = false,
    this.loadingSearch = false,
    this.loadingMore = false,
    this.errorMessage,
    this.searchPage = 0,
    this.searchTotalPages = 1,
  });

  bool get hasMoreSearch =>
      query.isNotEmpty && searchPage > 0 && searchPage < searchTotalPages;

  PlayerSearchState copyWith({
    List<PlayerProfile>? featuredPlayers,
    List<PlayerProfile>? searchResults,
    String? query,
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
        loadingFeatured,
        loadingSearch,
        loadingMore,
        errorMessage,
        searchPage,
        searchTotalPages,
      ];
}
