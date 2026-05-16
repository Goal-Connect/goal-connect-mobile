import 'package:goal_connect/features/auth/domain/entities/player_profile.dart';

class PlayerProfileModel extends PlayerProfile {
  const PlayerProfileModel({
    required super.id,
    required super.userId,
    super.academyId,
    super.fullName,
    super.dateOfBirth,
    super.position,
    super.primaryPosition,
    super.secondaryPosition,
    super.strongFoot,
    super.height,
    super.weight,
    super.jerseyNumber,
    super.profileImageUrl,
    super.bio,
    super.nationality,
    super.clubHistory,
    super.playingStyleTags,
    super.availabilityStatus,
    super.isAgeVerified,
    super.status,
    super.verificationStatus,
    super.verifiedAt,
    super.totalGoals,
    super.totalAssists,
    super.totalMatches,
    super.totalMinutesPlayed,
    super.disciplinaryRecord,
  });

  /// Parses the `profile` object from `/auth/me` response (or cached form).
  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    final disc = json['disciplinaryRecord'];
    DisciplinaryRecord discRecord = const DisciplinaryRecord();
    if (disc is Map) {
      discRecord = DisciplinaryRecord(
        yellowCards: _toInt(disc['yellowCards']) ?? 0,
        redCards: _toInt(disc['redCards']) ?? 0,
      );
    }

    return PlayerProfileModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      userId: (json['user'] ?? json['userId'])?.toString() ?? '',
      academyId: (json['academy'] ?? json['academyId'])?.toString(),
      fullName: json['fullName'] as String? ?? '',
      dateOfBirth: _toDate(json['dateOfBirth']),
      position: json['position'] as String? ?? '',
      primaryPosition: json['primaryPosition'] as String? ?? '',
      secondaryPosition: json['secondaryPosition'] as String?,
      strongFoot: json['strongFoot'] as String?,
      height: _toInt(json['height']),
      weight: _toInt(json['weight']),
      jerseyNumber: _toInt(json['jerseyNumber']),
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      clubHistory: _toStringList(json['clubHistory']),
      playingStyleTags: _toStringList(json['playingStyleTags']),
      availabilityStatus: json['availabilityStatus'] as String? ?? '',
      isAgeVerified: json['isAgeVerified'] == true,
      status: json['status'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? '',
      verifiedAt: _toDate(json['verifiedAt']),
      totalGoals: _toInt(json['totalGoals']) ?? 0,
      totalAssists: _toInt(json['totalAssists']) ?? 0,
      totalMatches: _toInt(json['totalMatches']) ?? 0,
      totalMinutesPlayed: _toInt(json['totalMinutesPlayed']) ?? 0,
      disciplinaryRecord: discRecord,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      if (academyId != null) 'academy': academyId,
      'fullName': fullName,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      'position': position,
      'primaryPosition': primaryPosition,
      if (secondaryPosition != null) 'secondaryPosition': secondaryPosition,
      if (strongFoot != null) 'strongFoot': strongFoot,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'nationality': nationality,
      'clubHistory': clubHistory,
      'playingStyleTags': playingStyleTags,
      'availabilityStatus': availabilityStatus,
      'isAgeVerified': isAgeVerified,
      'status': status,
      'verificationStatus': verificationStatus,
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
      'totalGoals': totalGoals,
      'totalAssists': totalAssists,
      'totalMatches': totalMatches,
      'totalMinutesPlayed': totalMinutesPlayed,
      'disciplinaryRecord': {
        'yellowCards': disciplinaryRecord.yellowCards,
        'redCards': disciplinaryRecord.redCards,
      },
    };
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}
