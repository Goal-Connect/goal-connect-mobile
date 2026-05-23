import 'package:equatable/equatable.dart';

import '../../domain/entities/scout_preference.dart';

enum ScoutPreferenceStatus { initial, loading, saving, ready, error }

class ScoutPreferenceState extends Equatable {
  final ScoutPreferenceStatus status;
  final ScoutPreference? preference;
  final bool justSaved;
  final bool justCleared;
  final String? errorMessage;

  const ScoutPreferenceState({
    this.status = ScoutPreferenceStatus.initial,
    this.preference,
    this.justSaved = false,
    this.justCleared = false,
    this.errorMessage,
  });

  bool get hasPreference =>
      preference != null && !(preference!.isEmpty);

  ScoutPreferenceState copyWith({
    ScoutPreferenceStatus? status,
    ScoutPreference? preference,
    bool clearPreference = false,
    bool? justSaved,
    bool? justCleared,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScoutPreferenceState(
      status: status ?? this.status,
      preference: clearPreference ? null : (preference ?? this.preference),
      justSaved: justSaved ?? false,
      justCleared: justCleared ?? false,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, preference, justSaved, justCleared, errorMessage];
}
