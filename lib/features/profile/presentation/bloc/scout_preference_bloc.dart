import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scout_preference.dart';
import '../../domain/usecases/delete_scout_preference_usecase.dart';
import '../../domain/usecases/get_scout_preference_usecase.dart';
import '../../domain/usecases/save_scout_preference_usecase.dart';
import 'scout_preference_event.dart';
import 'scout_preference_state.dart';

class ScoutPreferenceBloc
    extends Bloc<ScoutPreferenceEvent, ScoutPreferenceState> {
  final GetScoutPreferenceUsecase getPreference;
  final SaveScoutPreferenceUsecase savePreference;
  final DeleteScoutPreferenceUsecase deletePreference;

  ScoutPreferenceBloc({
    required this.getPreference,
    required this.savePreference,
    required this.deletePreference,
  }) : super(const ScoutPreferenceState()) {
    on<ScoutPreferenceLoadRequested>(_onLoad);
    on<ScoutPreferenceSaveRequested>(_onSave);
    on<ScoutPreferenceClearRequested>(_onClear);
  }

  Future<void> _onLoad(
    ScoutPreferenceLoadRequested event,
    Emitter<ScoutPreferenceState> emit,
  ) async {
    emit(state.copyWith(
      status: ScoutPreferenceStatus.loading,
      clearError: true,
    ));
    final result = await getPreference();
    result.fold(
      (_) => emit(state.copyWith(
        status: ScoutPreferenceStatus.error,
        errorMessage: 'Could not load preferences',
      )),
      (pref) => emit(state.copyWith(
        status: ScoutPreferenceStatus.ready,
        preference: pref,
        clearPreference: pref == null,
        clearError: true,
      )),
    );
  }

  Future<void> _onSave(
    ScoutPreferenceSaveRequested event,
    Emitter<ScoutPreferenceState> emit,
  ) async {
    final hadExisting = state.hasPreference;
    emit(state.copyWith(
      status: ScoutPreferenceStatus.saving,
      clearError: true,
    ));
    final next = ScoutPreference(
      positions: event.positions,
      regions: event.regions,
      minAge: event.minAge,
      maxAge: event.maxAge,
    );
    final result = await savePreference(
      preference: next,
      isUpdate: hadExisting,
    );
    result.fold(
      (_) => emit(state.copyWith(
        status: ScoutPreferenceStatus.error,
        errorMessage: 'Could not save preferences',
      )),
      (saved) => emit(state.copyWith(
        status: ScoutPreferenceStatus.ready,
        preference: saved,
        justSaved: true,
        clearError: true,
      )),
    );
  }

  Future<void> _onClear(
    ScoutPreferenceClearRequested event,
    Emitter<ScoutPreferenceState> emit,
  ) async {
    emit(state.copyWith(
      status: ScoutPreferenceStatus.saving,
      clearError: true,
    ));
    final result = await deletePreference();
    result.fold(
      (_) => emit(state.copyWith(
        status: ScoutPreferenceStatus.error,
        errorMessage: 'Could not clear preferences',
      )),
      (_) => emit(state.copyWith(
        status: ScoutPreferenceStatus.ready,
        clearPreference: true,
        justCleared: true,
        clearError: true,
      )),
    );
  }
}
