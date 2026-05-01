import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}
