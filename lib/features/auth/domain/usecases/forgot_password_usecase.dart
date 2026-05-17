import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<Either<Failure, String>> call(String email) =>
      repository.forgotPassword(email);
}
