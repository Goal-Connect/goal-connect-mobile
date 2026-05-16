import 'package:goal_connect/features/auth/domain/entities/scout_profile.dart';

class ScoutProfileModel extends ScoutProfile {
  const ScoutProfileModel({
    required super.id,
    required super.userId,
    super.fullName,
    super.organization,
    super.country,
    super.phone,
    super.profileImageUrl,
    super.preferredAgeRange,
    super.interestedPositions,
    super.preferredRegions,
    super.savedPlayersCount,
    super.recentlyViewedCount,
    super.documentsCount,
  });

  /// Parses the `profile` object from `/auth/me` for a scout (or its cached form).
  factory ScoutProfileModel.fromJson(Map<String, dynamic> json) {
    PreferredAgeRange range = const PreferredAgeRange();
    final ar = json['preferredAgeRange'];
    if (ar is Map) {
      range = PreferredAgeRange(
        min: _toInt(ar['min']),
        max: _toInt(ar['max']),
      );
    }

    return ScoutProfileModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['user'] ?? json['userId'])?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      country: json['country'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      preferredAgeRange: range,
      interestedPositions: _stringList(json['interestedPositions']),
      preferredRegions: _stringList(json['preferredRegions']),
      savedPlayersCount: _listLen(json['savedPlayers']),
      recentlyViewedCount: _listLen(json['recentlyViewed']),
      documentsCount: _listLen(json['documents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'fullName': fullName,
      'organization': organization,
      'country': country,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'preferredAgeRange': {
        if (preferredAgeRange.min != null) 'min': preferredAgeRange.min,
        if (preferredAgeRange.max != null) 'max': preferredAgeRange.max,
      },
      'interestedPositions': interestedPositions,
      'preferredRegions': preferredRegions,
      'savedPlayersCount': savedPlayersCount,
      'recentlyViewedCount': recentlyViewedCount,
      'documentsCount': documentsCount,
    };
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static int _listLen(dynamic v) => v is List ? v.length : 0;
}
