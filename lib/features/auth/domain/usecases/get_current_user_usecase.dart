import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, CurrentUserData>> call() =>
      repository.getCurrentUser();
}
