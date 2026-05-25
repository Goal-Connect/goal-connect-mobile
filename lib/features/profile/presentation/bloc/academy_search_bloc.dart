import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/usecases/list_academies_usecase.dart';

import 'academy_search_event.dart';
import 'academy_search_state.dart';

/// Drives the Academies tab of the scout search screen. Wraps
/// [ListAcademiesUsecase] and lets the UI swap query / region without
/// re-implementing debounce in the bloc — callers debounce in the page.
class AcademySearchBloc extends Bloc<AcademySearchEvent, AcademySearchState> {
  final ListAcademiesUsecase listAcademies;

  AcademySearchBloc({required this.listAcademies})
      : super(const AcademySearchState()) {
    on<AcademySearchLoadRequested>(_onLoadRequested);
    on<AcademySearchQueryChanged>(_onQueryChanged);
    on<AcademySearchRegionChanged>(_onRegionChanged);
    on<AcademySearchRefreshed>(_onRefreshed);
  }

  Future<void> _onLoadRequested(
    AcademySearchLoadRequested event,
    Emitter<AcademySearchState> emit,
  ) async {
    if (state.academies.isNotEmpty) return; // already populated
    await _fetch(emit, loading: true);
  }

  Future<void> _onQueryChanged(
    AcademySearchQueryChanged event,
    Emitter<AcademySearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query, clearError: true));
    await _fetch(emit, loading: true);
  }

  Future<void> _onRegionChanged(
    AcademySearchRegionChanged event,
    Emitter<AcademySearchState> emit,
  ) async {
    emit(state.copyWith(
      region: event.region,
      clearRegion: event.region == null,
      clearError: true,
    ));
    await _fetch(emit, loading: true);
  }

  Future<void> _onRefreshed(
    AcademySearchRefreshed event,
    Emitter<AcademySearchState> emit,
  ) async {
    await _fetch(emit, refreshing: true);
  }

  Future<void> _fetch(
    Emitter<AcademySearchState> emit, {
    bool loading = false,
    bool refreshing = false,
  }) async {
    emit(state.copyWith(
      loading: loading,
      refreshing: refreshing,
      clearError: true,
    ));

    final result = await listAcademies(
      search: state.query.isEmpty ? null : state.query,
      region: state.region,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        errorMessage: _messageFor(failure),
      )),
      (academies) => emit(state.copyWith(
        academies: academies,
        loading: false,
        refreshing: false,
      )),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is AuthFailure && failure.message != null) {
      return failure.message!;
    }
    return 'Could not load academies';
  }
}
