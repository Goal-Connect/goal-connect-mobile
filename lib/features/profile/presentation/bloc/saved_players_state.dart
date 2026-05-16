import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';

class SavedPlayersState extends Equatable {
  final bool loading;
  final List<PlayerProfile> players;
  final String? errorMessage;
  final Set<String> pendingIds;

  const SavedPlayersState({
    this.loading = false,
    this.players = const [],
    this.errorMessage,
    this.pendingIds = const {},
  });

  SavedPlayersState copyWith({
    bool? loading,
    List<PlayerProfile>? players,
    String? errorMessage,
    bool clearError = false,
    Set<String>? pendingIds,
  }) {
    return SavedPlayersState(
      loading: loading ?? this.loading,
      players: players ?? this.players,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [loading, players, errorMessage, pendingIds];
}
