class PlayerStats {
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defending;
  final int physical;
  final String preferredFoot;
  final int heightCm;
  final int weightKg;
  final String? currentClub;
  final int matchesPlayed;
  final int goals;
  final int assists;

  PlayerStats({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
    required this.preferredFoot,
    required this.heightCm,
    required this.weightKg,
    this.currentClub,
    required this.matchesPlayed,
    required this.goals,
    required this.assists,
  });

  int get overall =>
      ((pace + shooting + passing + dribbling + defending + physical) / 6).round();
}
