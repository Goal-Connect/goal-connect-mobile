import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../repositories/scout_preference_repository.dart';

class DeleteScoutPreferenceUsecase {
  final ScoutPreferenceRepository repository;

  DeleteScoutPreferenceUsecase(this.repository);

  Future<Either<Failure, void>> call() => repository.deletePreference();
}
