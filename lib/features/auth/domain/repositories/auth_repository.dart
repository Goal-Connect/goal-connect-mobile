import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/current_user_profile.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';

/// Carries the authenticated [User] plus the optional [CurrentUserProfile]
/// from `GET /auth/me`. [profile] is null for roles without a profile payload
/// (e.g. admin, academy).
class CurrentUserData {
  final User user;
  final CurrentUserProfile? profile;

  const CurrentUserData({required this.user, this.profile});
}

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> createScoutAccount(
    ScoutAccountRegistration registration,
  );

  /// `GET /auth/me` — refreshes user + player profile and persists both locally.
  Future<Either<Failure, CurrentUserData>> getCurrentUser();

  Future<Either<Failure, User>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> logout();

  /// Last successful user + profile from local cache (no network).
  Future<CurrentUserData?> getCachedUser();
}
