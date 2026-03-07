import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import '../entities/onboarding_info.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, OnboardingInfo>> getOnboardingStatus();
  Future<Either<Failure, void>> setOnboardingShown();
}
