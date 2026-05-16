import '../../domain/entities/player_profile.dart';
import 'player_stats_model.dart';

class PlayerProfileModel extends PlayerProfile {
  PlayerProfileModel({
    required super.id,
    super.userId,
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
    super.listingStatus = '',
    super.verificationStatus = '',
    super.availabilityStatus = '',
    super.academyName,
    super.academyRegion,
    super.secondaryPosition = '',
    super.primaryPosition = '',
    super.jerseyNumber = 0,
    super.strongFoot = '',
    super.yellowCards = 0,
    super.redCards = 0,
    super.isAgeVerified = false,
    super.dateOfBirth,
    super.heightCm,
    super.weightKg,
    super.nationality = '',
    super.playingStyleTags = const [],
    super.clubHistory = const [],
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
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
      listingStatus: json['listingStatus'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? '',
      availabilityStatus: json['availabilityStatus'] as String? ?? '',
      academyName: json['academyName'] as String?,
      academyRegion: json['academyRegion'] as String?,
      secondaryPosition: json['secondaryPosition'] as String? ?? '',
      jerseyNumber: json['jerseyNumber'] as int? ?? 0,
      strongFoot: json['strongFoot'] as String? ?? '',
      yellowCards: json['yellowCards'] as int? ?? 0,
      redCards: json['redCards'] as int? ?? 0,
      isAgeVerified: json['isAgeVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
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

  /// One element from `GET /players` `data[]` (same shape as single-player `data`).
  factory PlayerProfileModel.fromListDocument(Map<String, dynamic> json) {
    return PlayerProfileModel.fromPlayersEndpoint(<String, dynamic>{
      'success': true,
      'data': json,
    });
  }

  /// `GET /players/{id}` — `{ success, data }` with flat player document or nested `user` / `profile`.
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

    final userField = payload['user'];
    final hasNestedUser = userField is Map;
    final flatPlayerDoc = !hasNestedUser &&
        (payload.containsKey('fullName') ||
            payload.containsKey('profileImageUrl') ||
            payload.containsKey('nationality'));
    if (flatPlayerDoc) {
      return PlayerProfileModel._fromFlatPlayerPayload(payload);
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
    final rawUsername = u['username'] as String?;
    String username;
    if (fullName != null && fullName.trim().isNotEmpty) {
      username = fullName.trim();
    } else if (rawUsername != null && rawUsername.trim().isNotEmpty) {
      username = rawUsername.trim();
    } else if (email.contains('@')) {
      username = email.split('@').first;
    } else {
      username = 'Player';
    }
    final image = (prof?['profileImageUrl'] ??
            prof?['avatarUrl'] ??
            prof?['profileImage'] ??
            u['profileImage'] ??
            u['avatarUrl'])
        ?.toString() ??
        '';
    final position =
        prof?['primaryPosition'] as String? ??
            prof?['position'] as String? ??
            u['position'] as String? ??
            'Player';
    final age = PlayerProfileModel._asInt(u['age'], prof?['age'], 0);
    final country = prof?['nationality'] as String? ??
        prof?['country'] as String? ??
        u['country'] as String? ??
        '';
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
      userId: id,
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

  /// `GET /players/:id` when `data` is the player document (same shape as embedded profile).
  static PlayerProfileModel _fromFlatPlayerPayload(Map<String, dynamic> p) {
    final id = p['id']?.toString() ?? p['_id']?.toString() ?? '';
    final fullName = p['fullName'] as String? ?? '';
    final username = fullName.trim().isNotEmpty ? fullName.trim() : 'Player';
    final image = p['profileImageUrl']?.toString() ?? '';
    final position = p['primaryPosition'] as String? ??
        p['position'] as String? ??
        '';
    final age = PlayerProfileModel._asInt(p['age'], null, 0);
    final country = p['nationality'] as String? ?? '';
    final bio = p['bio'] as String?;

    final videos = p['videos'];
    final highlightsCount = videos is List ? videos.length : 0;

    String? academyName;
    String? academyRegion;
    final academy = p['academy'];
    if (academy is Map) {
      final am = Map<String, dynamic>.from(academy);
      academyName = am['name']?.toString();
      academyRegion = am['region']?.toString();
    }

    var yellow = 0;
    var red = 0;
    final disc = p['disciplinaryRecord'];
    if (disc is Map) {
      final dm = Map<String, dynamic>.from(disc);
      yellow = PlayerProfileModel._asInt(dm['yellowCards'], null, 0);
      red = PlayerProfileModel._asInt(dm['redCards'], null, 0);
    }

    final stats = PlayerStatsModel.fromFlatPlayerApi(p);

    final dob = DateTime.tryParse(p['dateOfBirth']?.toString() ?? '');
    final heightCm = PlayerProfileModel._asInt(p['height'], null, 0);
    final weightKg = PlayerProfileModel._asInt(p['weight'], null, 0);
    final tags = _stringList(p['playingStyleTags']);
    final clubs = _stringList(p['clubHistory']);

    return PlayerProfileModel(
      id: id,
      userId: p['user']?.toString(),
      username: username,
      email: '',
      role: 'player',
      profileImage: image,
      position: position.isEmpty ? 'Player' : position,
      age: age,
      country: country,
      bio: bio,
      highlightsCount: highlightsCount,
      followersCount: 0,
      followingCount: 0,
      totalLikes: 0,
      isFollowing: false,
      stats: stats,
      listingStatus: p['status']?.toString() ?? '',
      verificationStatus: p['verificationStatus']?.toString() ?? '',
      availabilityStatus: p['availabilityStatus']?.toString() ?? '',
      academyName: academyName,
      academyRegion: academyRegion,
      secondaryPosition: p['secondaryPosition'] as String? ?? '',
      primaryPosition: p['primaryPosition'] as String? ?? '',
      jerseyNumber: PlayerProfileModel._asInt(p['jerseyNumber'], null, 0),
      strongFoot: p['strongFoot']?.toString() ?? '',
      yellowCards: yellow,
      redCards: red,
      isAgeVerified: p['isAgeVerified'] as bool? ?? false,
      dateOfBirth: dob,
      heightCm: heightCm > 0 ? heightCm : null,
      weightKg: weightKg > 0 ? weightKg : null,
      nationality: p['nationality'] as String? ?? '',
      playingStyleTags: tags,
      clubHistory: clubs,
    );
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
