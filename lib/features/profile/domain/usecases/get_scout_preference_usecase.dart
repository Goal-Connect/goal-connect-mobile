import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/scout_preference.dart';
import '../repositories/scout_preference_repository.dart';

class GetScoutPreferenceUsecase {
  final ScoutPreferenceRepository repository;

  GetScoutPreferenceUsecase(this.repository);

  Future<Either<Failure, ScoutPreference?>> call() =>
      repository.getPreference();
}
