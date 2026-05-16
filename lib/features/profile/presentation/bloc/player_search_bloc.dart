import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/list_players_usecase.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc({required this.listPlayers}) : super(const PlayerSearchState()) {
    on<PlayerSearchLoadFeatured>(_onLoadFeatured);
    on<PlayerSearchQuerySubmitted>(_onQuerySubmitted);
    on<PlayerSearchLoadMore>(_onLoadMore);
    on<PlayerSearchFiltersApplied>(_onFiltersApplied);
    on<PlayerSearchFiltersCleared>(_onFiltersCleared);
  }

  final ListPlayersUsecase listPlayers;

  static const int _featuredLimit = 28;
  static const int _searchLimit = 20;

  Future<void> _onLoadFeatured(
    PlayerSearchLoadFeatured event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(state.copyWith(loadingFeatured: true, clearError: true));
    final result = await listPlayers(
      page: 1,
      limit: _featuredLimit,
    );
    result.fold(
      (_) => emit(state.copyWith(
        loadingFeatured: false,
        errorMessage: 'Could not load players',
      )),
      (data) => emit(state.copyWith(
        loadingFeatured: false,
        featuredPlayers: data.players,
      )),
    );
  }

  Future<void> _onQuerySubmitted(
    PlayerSearchQuerySubmitted event,
    Emitter<PlayerSearchState> emit,
  ) async {
    final q = event.query.trim();
    emit(state.copyWith(
      query: q,
      loadingSearch: true,
      clearError: true,
      searchResults: q.isEmpty && !state.filters.isActive ? [] : state.searchResults,
      searchPage: q.isEmpty && !state.filters.isActive ? 0 : state.searchPage,
    ));

    await _runSearch(emit, q, state.filters);
  }

  Future<void> _onFiltersApplied(
    PlayerSearchFiltersApplied event,
    Emitter<PlayerSearchState> emit,
  ) async {
    final next = PlayerSearchFilters(
      position: event.position,
      strongFoot: event.strongFoot,
      minAge: event.minAge,
      maxAge: event.maxAge,
      minHeight: event.minHeight,
      maxHeight: event.maxHeight,
    );
    emit(state.copyWith(
      filters: next,
      loadingSearch: true,
      clearError: true,
    ));
    await _runSearch(emit, state.query, next);
  }

  Future<void> _onFiltersCleared(
    PlayerSearchFiltersCleared event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(state.copyWith(
      filters: PlayerSearchFilters.empty,
      loadingSearch: true,
      clearError: true,
    ));
    await _runSearch(emit, state.query, PlayerSearchFilters.empty);
  }

  Future<void> _runSearch(
    Emitter<PlayerSearchState> emit,
    String query,
    PlayerSearchFilters filters,
  ) async {
    if (query.isEmpty && !filters.isActive) {
      emit(state.copyWith(
        loadingSearch: false,
        searchResults: [],
        searchPage: 0,
        searchTotalPages: 1,
      ));
      return;
    }

    final result = await listPlayers(
      page: 1,
      limit: _searchLimit,
      search: query.isEmpty ? null : query,
      position: filters.position,
      strongFoot: filters.strongFoot,
      minAge: filters.minAge,
      maxAge: filters.maxAge,
      minHeight: filters.minHeight,
      maxHeight: filters.maxHeight,
    );
    result.fold(
      (_) => emit(state.copyWith(
        loadingSearch: false,
        errorMessage: 'Search failed',
      )),
      (data) => emit(state.copyWith(
        loadingSearch: false,
        searchResults: data.players,
        searchPage: data.page,
        searchTotalPages: data.pages,
      )),
    );
  }

  Future<void> _onLoadMore(
    PlayerSearchLoadMore event,
    Emitter<PlayerSearchState> emit,
  ) async {
    if (!state.hasMoreSearch || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.searchPage + 1;
    final result = await listPlayers(
      page: nextPage,
      limit: _searchLimit,
      search: state.query.isEmpty ? null : state.query,
      position: state.filters.position,
      strongFoot: state.filters.strongFoot,
      minAge: state.filters.minAge,
      maxAge: state.filters.maxAge,
      minHeight: state.filters.minHeight,
      maxHeight: state.filters.maxHeight,
    );
    result.fold(
      (_) => emit(state.copyWith(loadingMore: false)),
      (data) => emit(state.copyWith(
        loadingMore: false,
        searchResults: [...state.searchResults, ...data.players],
        searchPage: data.page,
        searchTotalPages: data.pages,
      )),
    );
  }
}
