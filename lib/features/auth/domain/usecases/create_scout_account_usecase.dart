import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart'
    show Failure, ValidationFailure;
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class CreateScoutAccountUsecase {
  final AuthRepository repository;

  CreateScoutAccountUsecase(this.repository);

  Future<Either<Failure, User>> call(ScoutAccountRegistration registration) {
    if (!_isValid(registration)) {
      return Future.value(Left(ValidationFailure()));
    }
    return repository.createScoutAccount(registration);
  }

  bool _isValid(ScoutAccountRegistration r) {
    if (r.fullName.trim().isEmpty) return false;
    if (r.email.trim().isEmpty || !r.email.contains('@')) return false;
    if (r.password.length < 6) return false;
    if (r.nationalIdFanNo.trim().isEmpty) return false;
    if (r.phoneNumber.trim().isEmpty) return false;
    if (r.country.trim().isEmpty) return false;
    if (r.licencePhotoPath == null || r.licencePhotoPath!.trim().isEmpty) {
      return false;
    }
    return true;
  }
}
