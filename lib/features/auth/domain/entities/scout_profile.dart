class PreferredAgeRange {
  final int? min;
  final int? max;

  const PreferredAgeRange({this.min, this.max});

  bool get hasAny => min != null || max != null;
}

class ScoutProfile {
  final String id;
  final String userId;
  final String fullName;
  final String organization;
  final String country;
  final String phone;
  final String profileImageUrl;
  final PreferredAgeRange preferredAgeRange;
  final List<String> interestedPositions;
  final List<String> preferredRegions;
  final int savedPlayersCount;
  final int recentlyViewedCount;
  final int documentsCount;

  const ScoutProfile({
    required this.id,
    required this.userId,
    this.fullName = '',
    this.organization = '',
    this.country = '',
    this.phone = '',
    this.profileImageUrl = '',
    this.preferredAgeRange = const PreferredAgeRange(),
    this.interestedPositions = const [],
    this.preferredRegions = const [],
    this.savedPlayersCount = 0,
    this.recentlyViewedCount = 0,
    this.documentsCount = 0,
  });
}
