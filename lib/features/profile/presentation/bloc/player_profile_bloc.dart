import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_player_profile_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

class PlayerProfileBloc extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  final GetPlayerProfileUsecase getPlayerProfile;
  final ToggleFollowUsecase toggleFollow;

  PlayerProfileBloc({
    required this.getPlayerProfile,
    required this.toggleFollow,
  }) : super(PlayerProfileInitial()) {
    on<LoadPlayerProfileEvent>(_onLoadProfile);
    on<ToggleFollowEvent>(_onToggleFollow);
  }

  Future<void> _onLoadProfile(
    LoadPlayerProfileEvent event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(PlayerProfileLoading());
    final result = await getPlayerProfile(playerId: event.playerId);
    result.fold(
      (failure) => emit(const PlayerProfileError('Failed to load profile')),
      (profile) => emit(PlayerProfileLoaded(profile)),
    );
  }

  Future<void> _onToggleFollow(
    ToggleFollowEvent event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final current = state;
    if (current is! PlayerProfileLoaded) return;

    emit(FollowToggling(current.profile));

    final result = await toggleFollow(playerId: event.playerId);
    if (result.isLeft()) {
      emit(PlayerProfileLoaded(current.profile));
      return;
    }

    final refreshed = await getPlayerProfile(playerId: event.playerId);
    refreshed.fold(
      (failure) => emit(PlayerProfileLoaded(current.profile)),
      (profile) => emit(PlayerProfileLoaded(profile)),
    );
  }
}
