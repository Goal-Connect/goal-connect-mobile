import 'package:equatable/equatable.dart';
import 'package:goal_connect/features/auth/domain/entities/current_user_profile.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final CurrentUserProfile? profile;

  const AuthAuthenticated(this.user, {this.profile});

  @override
  List<Object?> get props => [user, profile];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
