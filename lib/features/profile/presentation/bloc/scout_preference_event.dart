import 'package:equatable/equatable.dart';

abstract class ScoutPreferenceEvent extends Equatable {
  const ScoutPreferenceEvent();

  @override
  List<Object?> get props => [];
}

class ScoutPreferenceLoadRequested extends ScoutPreferenceEvent {
  const ScoutPreferenceLoadRequested();
}

class ScoutPreferenceSaveRequested extends ScoutPreferenceEvent {
  final List<String> positions;
  final List<String> regions;
  final int? minAge;
  final int? maxAge;

  const ScoutPreferenceSaveRequested({
    this.positions = const [],
    this.regions = const [],
    this.minAge,
    this.maxAge,
  });

  @override
  List<Object?> get props => [positions, regions, minAge, maxAge];
}

class ScoutPreferenceClearRequested extends ScoutPreferenceEvent {
  const ScoutPreferenceClearRequested();
}
