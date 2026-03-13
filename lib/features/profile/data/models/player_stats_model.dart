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
