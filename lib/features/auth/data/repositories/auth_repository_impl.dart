import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      return Right(user);
    } catch (_) {
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, User>> createScoutAccount(
    ScoutAccountRegistration registration,
  ) async {
    try {
      final payload =
          ScoutAccountRegistrationModel.fromEntity(registration);
      final user = await remoteDataSource.createScoutAccount(payload);
      return Right(user);
    } catch (_) {
      return Left(AuthFailure());
    }
  }
}
