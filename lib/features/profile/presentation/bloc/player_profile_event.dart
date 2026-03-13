import 'package:equatable/equatable.dart';

abstract class PlayerProfileEvent extends Equatable {
  const PlayerProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlayerProfileEvent extends PlayerProfileEvent {
  final String playerId;

  const LoadPlayerProfileEvent(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class ToggleFollowEvent extends PlayerProfileEvent {
  final String playerId;

  const ToggleFollowEvent(this.playerId);

  @override
  List<Object?> get props => [playerId];
}
