import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/onboarding/domain/entities/onboarding_info.dart';
import 'package:goal_connect/features/onboarding/domain/repositories/onboarding_repository.dart';

class GetOnboardingStatusUsecase {
  final OnboardingRepository repository;
  GetOnboardingStatusUsecase(this.repository);

  Future<Either<Failure, OnboardingInfo>> call() {
    return repository.getOnboardingStatus();
  }
}
