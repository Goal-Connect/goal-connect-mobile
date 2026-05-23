class ScoutPreference {
  final List<String> positions;
  final List<String> regions;
  final int? minAge;
  final int? maxAge;

  const ScoutPreference({
    this.positions = const [],
    this.regions = const [],
    this.minAge,
    this.maxAge,
  });

  bool get isEmpty =>
      positions.isEmpty && regions.isEmpty && minAge == null && maxAge == null;

  /// Convenience for the feed filter, which only sends a single value per
  /// param. Returns the first selected entry or `null` when none.
  String? get firstPosition => positions.isEmpty ? null : positions.first;
  String? get firstRegion => regions.isEmpty ? null : regions.first;
}
