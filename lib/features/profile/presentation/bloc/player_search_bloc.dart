import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/list_players_usecase.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc({required this.listPlayers}) : super(const PlayerSearchState()) {
    on<PlayerSearchLoadFeatured>(_onLoadFeatured);
    on<PlayerSearchQuerySubmitted>(_onQuerySubmitted);
    on<PlayerSearchLoadMore>(_onLoadMore);
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
      searchResults: q.isEmpty ? [] : state.searchResults,
      searchPage: q.isEmpty ? 0 : state.searchPage,
    ));

    if (q.isEmpty) {
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
      search: q,
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
    if (!state.hasMoreSearch || state.loadingMore || state.query.isEmpty) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.searchPage + 1;
    final result = await listPlayers(
      page: nextPage,
      limit: _searchLimit,
      search: state.query,
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
