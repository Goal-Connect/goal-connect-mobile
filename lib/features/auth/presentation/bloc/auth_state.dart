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

/// Login/registration succeeded but the account is not yet approved
/// (e.g. scout awaiting admin verification). The session has been signed out.
class AuthPendingApproval extends AuthState {
  final String email;
  final String role;

  /// True when the user just submitted a registration; false when an
  /// already-registered user tried to sign in while still pending.
  final bool justRegistered;

  const AuthPendingApproval({
    required this.email,
    required this.role,
    this.justRegistered = false,
  });

  @override
  List<Object?> get props => [email, role, justRegistered];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
