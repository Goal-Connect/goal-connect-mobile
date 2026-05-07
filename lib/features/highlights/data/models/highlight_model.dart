import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../../domain/entities/highlight.dart';

class HighlightModel extends Highlight {
  HighlightModel({
    required super.id,
    required super.player,
    required super.videoUrl,
    required super.caption,
    required super.likes,
    super.commentCount,
    required super.createdAt,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      id: json['id'],
      player: User(
        id: json['player']['id'],
        email: json['player']['email'],
        role: json['player']['role'],
        username: json['player']['username'],
        profileImage: json['player']['profileImage'],
        position: json['player']['position'],
        age: json['player']['age'],
        country: json['player']['country'],
      ),
      videoUrl: json['videoUrl'],
      caption: json['caption'],
      likes: json['likes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// One item from `GET /videos/feed` (wrapped `video` + `player` + `academy`).
  factory HighlightModel.fromFeedItemMap(Map<String, dynamic> json) {
    final videoRaw = json['video'];
    final playerRaw = json['player'];
    if (videoRaw is! Map || playerRaw is! Map) {
      throw const FormatException('Invalid feed item');
    }
    final v = Map<String, dynamic>.from(videoRaw);
    final p = Map<String, dynamic>.from(playerRaw);

    final videoId = (v['_id'] ?? v['id'])?.toString() ?? '';
    final title = v['title'] as String? ?? '';
    final description = v['description'] as String? ?? '';
    final caption = title.isNotEmpty
        ? title
        : (description.isNotEmpty ? description : 'Highlight');

    final likesRaw = v['likes'];
    final likeCount = likesRaw is List
        ? likesRaw.length
        : (likesRaw is int
            ? likesRaw
            : int.tryParse(likesRaw?.toString() ?? '') ?? 0);

    var createdAt = DateTime.now();
    final createdRaw = v['createdAt'] ?? json['createdAt'];
    if (createdRaw != null) {
      createdAt = DateTime.tryParse(createdRaw.toString()) ?? createdAt;
    }

    final playerId = (p['id'] ?? p['_id'])?.toString() ?? '';
    final fullName = p['fullName'] as String? ?? 'Player';
    final profileImageUrl = p['profileImageUrl'] as String? ?? '';
    final position = p['position'] as String? ?? '';
    final ageVal = p['age'];
    final age = ageVal is int
        ? ageVal
        : int.tryParse(ageVal?.toString() ?? '') ?? 0;

    final id = videoId.isNotEmpty
        ? videoId
        : (json['_id'] ?? json['id'])?.toString() ?? '';

    return HighlightModel(
      id: id.isEmpty ? 'unknown' : id,
      player: User(
        id: playerId.isEmpty ? 'unknown' : playerId,
        email: '',
        role: 'player',
        username: fullName,
        profileImage: profileImageUrl,
        position: position.isEmpty ? 'Player' : position,
        age: age,
        country: '',
      ),
      videoUrl: v['videoUrl'] as String? ?? '',
      caption: caption,
      likes: likeCount,
      commentCount: 0,
      createdAt: createdAt,
    );
  }

  /// One item from `GET /videos` or `data` from `POST /videos` (see README).
  factory HighlightModel.fromVideoApiMap(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final playerRef = json['player'];
    final playerId = playerRef == null
        ? ''
        : (playerRef is String ? playerRef : playerRef.toString());
    final title = json['title'] as String? ?? '';
    final description = json['description'] as String? ?? '';
    final caption = title.isNotEmpty
        ? title
        : (description.isNotEmpty ? description : 'Highlight');
    final videoUrl = json['videoUrl'] as String? ?? '';
    final thumbnailUrl = json['thumbnailUrl'] as String? ?? '';
    final views = json['views'];
    final likes = views is int
        ? views
        : int.tryParse(views?.toString() ?? '') ?? 0;
    DateTime createdAt = DateTime.now();
    final createdRaw = json['createdAt'];
    if (createdRaw != null) {
      createdAt = DateTime.tryParse(createdRaw.toString()) ?? createdAt;
    }
    return HighlightModel(
      id: id,
      player: User(
        id: playerId.isEmpty ? 'unknown' : playerId,
        email: '',
        role: 'player',
        username: 'Player',
        profileImage: thumbnailUrl,
        position: 'Player',
        age: 0,
        country: '',
      ),
      videoUrl: videoUrl,
      caption: caption,
      likes: likes,
      commentCount: 0,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player': {
        'id': player.id,
        'email': player.email,
        'role': player.role,
        'username': player.username,
        'profileImage': player.profileImage,
        'position': player.position,
        'age': player.age,
        'country': player.country,
      },
      'videoUrl': videoUrl,
      'caption': caption,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
