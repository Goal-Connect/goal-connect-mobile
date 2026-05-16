import 'package:equatable/equatable.dart';

abstract class SavedPlayersEvent extends Equatable {
  const SavedPlayersEvent();

  @override
  List<Object?> get props => [];
}

class SavedPlayersLoaded extends SavedPlayersEvent {
  const SavedPlayersLoaded();
}

class SavedPlayersRefreshed extends SavedPlayersEvent {
  const SavedPlayersRefreshed();
}

class SavedPlayerRemoved extends SavedPlayersEvent {
  final String playerId;
  const SavedPlayerRemoved(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class SavedPlayerAdded extends SavedPlayersEvent {
  final String playerId;
  const SavedPlayerAdded(this.playerId);

  @override
  List<Object?> get props => [playerId];
}
