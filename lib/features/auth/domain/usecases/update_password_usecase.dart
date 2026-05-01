import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart'
    show Failure, ValidationFailure;
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository repository;

  UpdatePasswordUsecase(this.repository);

  Future<Either<Failure, User>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    if (currentPassword.isEmpty || newPassword.length < 6) {
      return Future.value(Left(ValidationFailure()));
    }
    return repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
