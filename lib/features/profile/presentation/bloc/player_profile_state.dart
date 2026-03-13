import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';

abstract class PlayerProfileState extends Equatable {
  const PlayerProfileState();

  @override
  List<Object?> get props => [];
}

class PlayerProfileInitial extends PlayerProfileState {}

class PlayerProfileLoading extends PlayerProfileState {}

class PlayerProfileLoaded extends PlayerProfileState {
  final PlayerProfile profile;

  const PlayerProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class PlayerProfileError extends PlayerProfileState {
  final String message;

  const PlayerProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class FollowToggling extends PlayerProfileState {
  final PlayerProfile profile;

  const FollowToggling(this.profile);

  @override
  List<Object?> get props => [profile];
}
