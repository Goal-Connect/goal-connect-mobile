import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../domain/entities/onboarding_info.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, OnboardingInfo>> getOnboardingStatus() async {
    try {
      final info = await localDataSource.getOnboardingStatus();
      return Right(info);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setOnboardingShown() async {
    try {
      await localDataSource.setOnboardingShown();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
