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

  /// `GET /players/{id}` — supports `{ success, data }` or nested `user` / `profile`.
  factory PlayerProfileModel.fromPlayersEndpoint(dynamic body) {
    if (body is! Map) {
      throw const FormatException('Invalid player response');
    }
    final root = Map<String, dynamic>.from(body);
    Map<String, dynamic> payload;
    if (root['success'] == true && root['data'] is Map) {
      payload = Map<String, dynamic>.from(root['data'] as Map);
    } else {
      payload = root;
    }

    Map<String, dynamic> u;
    Map<String, dynamic>? prof;
    if (payload['user'] is Map) {
      u = Map<String, dynamic>.from(payload['user'] as Map);
      if (payload['profile'] is Map) {
        prof = Map<String, dynamic>.from(payload['profile'] as Map);
      }
    } else {
      u = payload;
      prof = payload['profile'] is Map
          ? Map<String, dynamic>.from(payload['profile'] as Map)
          : null;
    }

    final id = u['_id']?.toString() ?? u['id']?.toString() ?? '';
    final email = u['email'] as String? ?? '';
    final role = u['role'] as String? ?? 'player';
    final fullName = prof?['fullName'] as String?;
    final username = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : (u['username'] as String? ??
            (email.contains('@') ? email.split('@').first : id));
    final image = (prof?['avatarUrl'] ??
            prof?['profileImage'] ??
            u['profileImage'] ??
            u['avatarUrl'])
        ?.toString() ??
        '';
    final position =
        prof?['position'] as String? ?? u['position'] as String? ?? 'Player';
    final age = PlayerProfileModel._asInt(u['age'], prof?['age'], 0);
    final country =
        prof?['country'] as String? ?? u['country'] as String? ?? '';
    final bio = prof?['bio'] as String? ?? u['bio'] as String?;

    final highlightsCount = PlayerProfileModel._asInt(
      prof?['highlightsCount'],
      u['highlightsCount'],
      0,
    );
    final followersCount = PlayerProfileModel._asInt(
      prof?['followersCount'],
      u['followersCount'],
      0,
    );
    final followingCount = PlayerProfileModel._asInt(
      prof?['followingCount'],
      u['followingCount'],
      0,
    );
    final totalLikes =
        PlayerProfileModel._asInt(prof?['totalLikes'], u['totalLikes'], 0);
    final isFollowing =
        prof?['isFollowing'] as bool? ?? u['isFollowing'] as bool? ?? false;

    PlayerStatsModel? stats;
    final statsRaw = prof?['stats'] ?? u['stats'] ?? payload['stats'];
    if (statsRaw is Map) {
      stats = PlayerStatsModel.fromApiMap(
        Map<String, dynamic>.from(statsRaw),
      );
    } else {
      stats = PlayerStatsModel.defaults();
    }

    return PlayerProfileModel(
      id: id,
      username: username,
      email: email,
      role: role,
      profileImage: image,
      position: position,
      age: age,
      country: country,
      bio: bio,
      highlightsCount: highlightsCount,
      followersCount: followersCount,
      followingCount: followingCount,
      totalLikes: totalLikes,
      isFollowing: isFollowing,
      stats: stats,
    );
  }

  static int _asInt(dynamic a, dynamic b, int fallback) {
    for (final v in [a, b]) {
      if (v == null) {
        continue;
      }
      if (v is int) {
        return v;
      }
      if (v is double) {
        return v.round();
      }
      final p = int.tryParse(v.toString());
      if (p != null) {
        return p;
      }
    }
    return fallback;
  }
}
