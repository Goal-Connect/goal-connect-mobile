import 'package:dartz/dartz.dart';
import '../../../../core/error/fialures.dart';
import '../entities/scout_preference.dart';

abstract class ScoutPreferenceRepository {
  /// Load the currently saved preference for this scout (read-through cache).
  /// Returns null when no preference has been set yet.
  Future<Either<Failure, ScoutPreference?>> getPreference();

  Future<Either<Failure, ScoutPreference>> savePreference(
    ScoutPreference preference,
  );

  Future<Either<Failure, ScoutPreference>> updatePreference(
    ScoutPreference preference,
  );

  Future<Either<Failure, void>> deletePreference();
}
