import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart' show Failure;
import 'package:goal_connect/features/auth/domain/entities/academy.dart';
import 'package:goal_connect/features/auth/domain/repositories/auth_repository.dart';

class ListAcademiesUsecase {
  final AuthRepository repository;

  ListAcademiesUsecase(this.repository);

  Future<Either<Failure, List<Academy>>> call({
    String? search,
    String? region,
  }) {
    return repository.listAcademies(search: search, region: region);
  }
}
