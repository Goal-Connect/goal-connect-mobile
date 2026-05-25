import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart'
    show Failure, ValidationFailure;
import 'package:goal_connect/features/auth/domain/entities/player_application.dart';
import 'package:goal_connect/features/auth/domain/repositories/auth_repository.dart';

class SubmitPlayerApplicationUsecase {
  final AuthRepository repository;

  SubmitPlayerApplicationUsecase(this.repository);

  Future<Either<Failure, PlayerApplicationReceipt>> call(
    PlayerApplication application,
  ) {
    if (!_isValid(application)) {
      return Future.value(Left(ValidationFailure()));
    }
    return repository.submitPlayerApplication(application);
  }

  bool _isValid(PlayerApplication a) {
    if (a.fullName.trim().isEmpty) return false;
    if (a.email.trim().isEmpty || !a.email.contains('@')) return false;
    if (a.nationalIdFanNo.trim().isEmpty) return false;
    if (a.age < 10 || a.age > 60) return false;
    if (a.phoneNumber.trim().isEmpty) return false;
    if (a.address.trim().isEmpty) return false;
    if (a.country.trim().isEmpty) return false;
    if (a.region.trim().isEmpty) return false;
    if (a.primaryPosition.trim().isEmpty) return false;
    if (a.academyId.trim().isEmpty) return false;
    if (a.secondaryPosition != null &&
        a.secondaryPosition!.isNotEmpty &&
        a.secondaryPosition == a.primaryPosition) {
      return false;
    }
    return true;
  }
}
