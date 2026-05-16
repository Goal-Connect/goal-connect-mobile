class DisciplinaryRecord {
  final int yellowCards;
  final int redCards;

  const DisciplinaryRecord({
    this.yellowCards = 0,
    this.redCards = 0,
  });
}

class PlayerProfile {
  final String id;
  final String userId;
  final String? academyId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String position;
  final String primaryPosition;
  final String? secondaryPosition;
  final String? strongFoot;
  final int? height;
  final int? weight;
  final int? jerseyNumber;
  final String profileImageUrl;
  final String bio;
  final String nationality;
  final List<String> clubHistory;
  final List<String> playingStyleTags;
  final String availabilityStatus;
  final bool isAgeVerified;
  final String status;
  final String verificationStatus;
  final DateTime? verifiedAt;
  final int totalGoals;
  final int totalAssists;
  final int totalMatches;
  final int totalMinutesPlayed;
  final DisciplinaryRecord disciplinaryRecord;

  const PlayerProfile({
    required this.id,
    required this.userId,
    this.academyId,
    this.fullName = '',
    this.dateOfBirth,
    this.position = '',
    this.primaryPosition = '',
    this.secondaryPosition,
    this.strongFoot,
    this.height,
    this.weight,
    this.jerseyNumber,
    this.profileImageUrl = '',
    this.bio = '',
    this.nationality = '',
    this.clubHistory = const [],
    this.playingStyleTags = const [],
    this.availabilityStatus = '',
    this.isAgeVerified = false,
    this.status = '',
    this.verificationStatus = '',
    this.verifiedAt,
    this.totalGoals = 0,
    this.totalAssists = 0,
    this.totalMatches = 0,
    this.totalMinutesPlayed = 0,
    this.disciplinaryRecord = const DisciplinaryRecord(),
  });

  int? get ageYears {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }
}
