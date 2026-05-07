import '../../domain/entities/player_stats.dart';

class PlayerStatsModel extends PlayerStats {
  PlayerStatsModel({
    required super.pace,
    required super.shooting,
    required super.passing,
    required super.dribbling,
    required super.defending,
    required super.physical,
    required super.preferredFoot,
    required super.heightCm,
    required super.weightKg,
    super.currentClub,
    required super.matchesPlayed,
    required super.goals,
    required super.assists,
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      pace: json['pace'] as int,
      shooting: json['shooting'] as int,
      passing: json['passing'] as int,
      dribbling: json['dribbling'] as int,
      defending: json['defending'] as int,
      physical: json['physical'] as int,
      preferredFoot: json['preferredFoot'] as String,
      heightCm: json['heightCm'] as int,
      weightKg: json['weightKg'] as int,
      currentClub: json['currentClub'] as String?,
      matchesPlayed: json['matchesPlayed'] as int,
      goals: json['goals'] as int,
      assists: json['assists'] as int,
    );
  }

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v is int) {
      return v;
    }
    if (v is double) {
      return v.round();
    }
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  factory PlayerStatsModel.fromFlatPlayerApi(Map<String, dynamic> p) {
    final footRaw = p['strongFoot']?.toString() ?? 'right';
    final footLabel = footRaw.isEmpty
        ? 'Right'
        : '${footRaw[0].toUpperCase()}${footRaw.length > 1 ? footRaw.substring(1) : ''}';
    String? club;
    final academy = p['academy'];
    if (academy is Map) {
      club = academy['name']?.toString();
    }
    return PlayerStatsModel(
      pace: 50,
      shooting: 50,
      passing: 50,
      dribbling: 50,
      defending: 50,
      physical: 50,
      preferredFoot: footLabel,
      heightCm: _asInt(p['height'], 170),
      weightKg: _asInt(p['weight'], 65),
      currentClub: club,
      matchesPlayed: _asInt(p['totalMatches'], 0),
      goals: _asInt(p['totalGoals'], 0),
      assists: _asInt(p['totalAssists'], 0),
    );
  }

  /// Fallback when API omits stats block.
  factory PlayerStatsModel.defaults() {
    return PlayerStatsModel(
      pace: 50,
      shooting: 50,
      passing: 50,
      dribbling: 50,
      defending: 50,
      physical: 50,
      preferredFoot: 'Right',
      heightCm: 170,
      weightKg: 65,
      currentClub: null,
      matchesPlayed: 0,
      goals: 0,
      assists: 0,
    );
  }

  factory PlayerStatsModel.fromApiMap(Map<String, dynamic> json) {
    return PlayerStatsModel(
      pace: _asInt(json['pace'], 50),
      shooting: _asInt(json['shooting'], 50),
      passing: _asInt(json['passing'], 50),
      dribbling: _asInt(json['dribbling'], 50),
      defending: _asInt(json['defending'], 50),
      physical: _asInt(json['physical'], 50),
      preferredFoot: json['preferredFoot']?.toString() ?? 'Right',
      heightCm: _asInt(json['heightCm'], 170),
      weightKg: _asInt(json['weightKg'], 65),
      currentClub: json['currentClub']?.toString(),
      matchesPlayed: _asInt(json['matchesPlayed'], 0),
      goals: _asInt(json['goals'], 0),
      assists: _asInt(json['assists'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'dribbling': dribbling,
      'defending': defending,
      'physical': physical,
      'preferredFoot': preferredFoot,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'currentClub': currentClub,
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
    };
  }
}
