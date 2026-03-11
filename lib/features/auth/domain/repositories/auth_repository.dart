import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
}
