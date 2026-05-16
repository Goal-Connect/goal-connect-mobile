import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_saved_players_usecase.dart';
import '../../domain/usecases/save_player_usecase.dart';
import '../../domain/usecases/unsave_player_usecase.dart';
import 'saved_players_event.dart';
import 'saved_players_state.dart';

class SavedPlayersBloc extends Bloc<SavedPlayersEvent, SavedPlayersState> {
  final GetSavedPlayersUsecase getSavedPlayers;
  final SavePlayerUsecase savePlayer;
  final UnsavePlayerUsecase unsavePlayer;

  SavedPlayersBloc({
    required this.getSavedPlayers,
    required this.savePlayer,
    required this.unsavePlayer,
  }) : super(const SavedPlayersState()) {
    on<SavedPlayersLoaded>(_onLoad);
    on<SavedPlayersRefreshed>(_onRefresh);
    on<SavedPlayerRemoved>(_onRemove);
    on<SavedPlayerAdded>(_onAdd);
  }

  Future<void> _onLoad(
    SavedPlayersLoaded event,
    Emitter<SavedPlayersState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await getSavedPlayers();
    result.fold(
      (_) => emit(state.copyWith(
        loading: false,
        errorMessage: 'Could not load saved players',
      )),
      (list) => emit(state.copyWith(loading: false, players: list)),
    );
  }

  Future<void> _onRefresh(
    SavedPlayersRefreshed event,
    Emitter<SavedPlayersState> emit,
  ) async {
    final result = await getSavedPlayers();
    result.fold(
      (_) => emit(state.copyWith(
        errorMessage: 'Could not refresh saved players',
      )),
      (list) => emit(state.copyWith(players: list, clearError: true)),
    );
  }

  Future<void> _onRemove(
    SavedPlayerRemoved event,
    Emitter<SavedPlayersState> emit,
  ) async {
    final id = event.playerId;
    if (state.pendingIds.contains(id)) return;

    final previous = state.players;
    final optimistic = previous.where((p) => p.id != id).toList();
    final pending = {...state.pendingIds, id};
    emit(state.copyWith(
      players: optimistic,
      pendingIds: pending,
      clearError: true,
    ));

    final result = await unsavePlayer(playerId: id);
    final nextPending = {...state.pendingIds}..remove(id);
    result.fold(
      (_) => emit(state.copyWith(
        players: previous,
        pendingIds: nextPending,
        errorMessage: 'Could not unsave player',
      )),
      (_) => emit(state.copyWith(pendingIds: nextPending)),
    );
  }

  Future<void> _onAdd(
    SavedPlayerAdded event,
    Emitter<SavedPlayersState> emit,
  ) async {
    final id = event.playerId;
    if (state.pendingIds.contains(id)) return;
    emit(state.copyWith(
      pendingIds: {...state.pendingIds, id},
      clearError: true,
    ));
    final result = await savePlayer(playerId: id);
    final nextPending = {...state.pendingIds}..remove(id);
    await result.fold(
      (_) async => emit(state.copyWith(
        pendingIds: nextPending,
        errorMessage: 'Could not save player',
      )),
      (_) async {
        emit(state.copyWith(pendingIds: nextPending));
        add(const SavedPlayersRefreshed());
      },
    );
  }
}
