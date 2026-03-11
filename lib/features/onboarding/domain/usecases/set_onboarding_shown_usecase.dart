import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/onboarding/domain/repositories/onboarding_repository.dart';

class SetOnboardingShownUsecase {
  final OnboardingRepository repository;
  SetOnboardingShownUsecase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.setOnboardingShown();
  }
}
