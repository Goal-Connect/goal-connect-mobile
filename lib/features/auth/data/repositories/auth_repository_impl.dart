import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_token_local_datasource.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import 'package:goal_connect/features/auth/data/models/auth_remote_session.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthTokenLocalDataSource tokenStorage;
  final AuthUserLocalDataSource userCache;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.userCache,
  });

  Future<void> _persistSession(
    AuthRemoteSession session, {
    String? profileJson,
  }) async {
    await tokenStorage.saveToken(session.token);
    await userCache.saveUserAndProfile(
      user: session.user,
      profileJson: profileJson,
    );
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await _persistSession(session);
      return Right(session.user);
    } on AuthApiException catch (e) {
      return Left(AuthFailure(e.message));
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
      final session = await remoteDataSource.createScoutAccount(payload);
      await _persistSession(session);
      return Right(session.user);
    } on AuthApiException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, CurrentUserData>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      await userCache.saveUserAndProfile(
        user: result.user,
        profileJson: result.profileJson,
      );
      return Right(CurrentUserData(user: result.user, profile: result.profile));
    } on AuthApiException catch (e) {
      if (e.statusCode == 401) {
        await tokenStorage.clearToken();
        await userCache.clear();
      }
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final session = await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _persistSession(session);
      return Right(session.user);
    } on AuthApiException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logoutAck();
    } catch (_) {
      // README: client must clear token regardless; still attempt sign-out call.
    }
    try {
      await tokenStorage.clearToken();
      await userCache.clear();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<CurrentUserData?> getCachedUser() async {
    final user = await userCache.readCachedUser();
    if (user == null) return null;
    final profile = await userCache.readCachedProfile();
    return CurrentUserData(user: user, profile: profile);
  }
}
