import 'player_stats.dart';

class PlayerProfile {
  final String id;

  /// Auth user id (`users` document) when distinct from [id] (e.g. list payload has `user`).
  final String? userId;
  final String username;
  final String email;
  final String role;
  final String profileImage;
  final String position;
  final int age;
  final String country;
  final String? bio;
  final int highlightsCount;
  final int followersCount;
  final int followingCount;
  final int totalLikes;
  final bool isFollowing;
  final PlayerStats? stats;

  /// `GET /players/:id` — `status` (e.g. active).
  final String listingStatus;
  final String verificationStatus;
  final String availabilityStatus;
  final String? academyName;
  final String? academyRegion;
  final String secondaryPosition;
  final String primaryPosition;
  final int jerseyNumber;
  final String strongFoot;
  final int yellowCards;
  final int redCards;
  final bool isAgeVerified;
  final DateTime? dateOfBirth;
  final int? heightCm;
  final int? weightKg;
  final String nationality;
  final List<String> playingStyleTags;
  final List<String> clubHistory;

  PlayerProfile({
    required this.id,
    this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.profileImage,
    required this.position,
    required this.age,
    required this.country,
    this.bio,
    required this.highlightsCount,
    required this.followersCount,
    required this.followingCount,
    required this.totalLikes,
    required this.isFollowing,
    this.stats,
    this.listingStatus = '',
    this.verificationStatus = '',
    this.availabilityStatus = '',
    this.academyName,
    this.academyRegion,
    this.secondaryPosition = '',
    this.primaryPosition = '',
    this.jerseyNumber = 0,
    this.strongFoot = '',
    this.yellowCards = 0,
    this.redCards = 0,
    this.isAgeVerified = false,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.nationality = '',
    this.playingStyleTags = const [],
    this.clubHistory = const [],
  });

  bool get isPlayer => role == 'player';

  /// User id to use for `GET/POST /messages` (peer account id).
  String get messagingUserId => userId ?? id;
}
