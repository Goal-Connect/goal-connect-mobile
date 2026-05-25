import 'package:equatable/equatable.dart';
import 'package:goal_connect/features/auth/domain/entities/academy.dart';

class AcademySearchState extends Equatable {
  final List<Academy> academies;
  final String query;
  final String? region;
  final bool loading;
  final bool refreshing;
  final String? errorMessage;

  const AcademySearchState({
    this.academies = const [],
    this.query = '',
    this.region,
    this.loading = false,
    this.refreshing = false,
    this.errorMessage,
  });

  /// Returns true while there's no data on screen yet.
  bool get isInitial => academies.isEmpty && !loading && errorMessage == null;

  AcademySearchState copyWith({
    List<Academy>? academies,
    String? query,
    String? region,
    bool? loading,
    bool? refreshing,
    String? errorMessage,
    bool clearError = false,
    bool clearRegion = false,
  }) {
    return AcademySearchState(
      academies: academies ?? this.academies,
      query: query ?? this.query,
      region: clearRegion ? null : (region ?? this.region),
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [academies, query, region, loading, refreshing, errorMessage];
}
