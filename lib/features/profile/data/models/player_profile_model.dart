import '../../domain/entities/player_profile.dart';
import 'player_stats_model.dart';

class PlayerProfileModel extends PlayerProfile {
  PlayerProfileModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    required super.profileImage,
    required super.position,
    required super.age,
    required super.country,
    super.bio,
    required super.highlightsCount,
    required super.followersCount,
    required super.followingCount,
    required super.totalLikes,
    required super.isFollowing,
    super.stats,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String,
      position: json['position'] as String,
      age: json['age'] as int,
      country: json['country'] as String,
      bio: json['bio'] as String?,
      highlightsCount: json['highlightsCount'] as int,
      followersCount: json['followersCount'] as int,
      followingCount: json['followingCount'] as int,
      totalLikes: json['totalLikes'] as int,
      isFollowing: json['isFollowing'] as bool,
      stats: json['stats'] != null
          ? PlayerStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'position': position,
      'age': age,
      'country': country,
      'bio': bio,
      'highlightsCount': highlightsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'totalLikes': totalLikes,
      'isFollowing': isFollowing,
    };
  }
}
