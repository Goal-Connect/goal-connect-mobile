import 'package:equatable/equatable.dart';

abstract class AcademySearchEvent extends Equatable {
  const AcademySearchEvent();
  @override
  List<Object?> get props => [];
}

/// First-load: pull the full approved-academies list.
class AcademySearchLoadRequested extends AcademySearchEvent {
  const AcademySearchLoadRequested();
}

/// User typed in the search field. Debounce client-side; the bloc treats
/// every event as the new query.
class AcademySearchQueryChanged extends AcademySearchEvent {
  final String query;
  const AcademySearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// User picked / cleared a region filter chip.
class AcademySearchRegionChanged extends AcademySearchEvent {
  final String? region;
  const AcademySearchRegionChanged(this.region);
  @override
  List<Object?> get props => [region];
}

/// Pull-to-refresh.
class AcademySearchRefreshed extends AcademySearchEvent {
  const AcademySearchRefreshed();
}
