import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> createScoutAccount(
    ScoutAccountRegistration registration,
  );

  /// `GET /auth/me` — refreshes profile and persists user (+ profile JSON) locally.
  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> logout();

  /// Last successful user from local cache (no network).
  Future<User?> getCachedUser();
}
