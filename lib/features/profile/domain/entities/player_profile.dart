import 'player_stats.dart';

class PlayerProfile {
  final String id;
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

  PlayerProfile({
    required this.id,
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
  });

  bool get isPlayer => role == 'player';
}
