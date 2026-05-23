import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/scout_preference.dart';
import '../repositories/scout_preference_repository.dart';

class SaveScoutPreferenceUsecase {
  final ScoutPreferenceRepository repository;

  SaveScoutPreferenceUsecase(this.repository);

  Future<Either<Failure, ScoutPreference>> call({
    required ScoutPreference preference,
    required bool isUpdate,
  }) {
    return isUpdate
        ? repository.updatePreference(preference)
        : repository.savePreference(preference);
  }
}
