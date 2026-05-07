import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../../domain/entities/highlight.dart';

class HighlightModel extends Highlight {
  HighlightModel({
    required super.id,
    required super.player,
    required super.videoUrl,
    required super.caption,
    required super.likes,
    super.likedUserIds,
    super.commentCount,
    required super.createdAt,
    super.description,
    super.privacy,
    super.drillType,
    super.videoType,
    super.thumbnailUrl,
    super.uploadedById,
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

  static List<String> _parseLikeIds(dynamic likesRaw) {
    if (likesRaw is List) {
      return likesRaw.map((e) => e.toString()).toList();
    }
    return [];
  }

  static int _parseLikeCount(dynamic likesRaw, dynamic likesCountRaw) {
    if (likesRaw is List) return likesRaw.length;
    if (likesCountRaw is int) return likesCountRaw;
    if (likesRaw is int) return likesRaw;
    return int.tryParse(likesCountRaw?.toString() ?? '') ?? 0;
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
    final likeCount = _parseLikeCount(likesRaw, v['likesCount']);
    final likedIds = _parseLikeIds(likesRaw);

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

    final uploadedBy = v['uploadedBy'];
    final uploadedById = uploadedBy == null
        ? null
        : (uploadedBy is String ? uploadedBy : uploadedBy.toString());

    final thumb = v['thumbnailUrl'] as String? ?? '';

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
      likedUserIds: likedIds,
      commentCount: int.tryParse(v['commentsCount']?.toString() ?? '') ??
          int.tryParse(json['commentsCount']?.toString() ?? '') ??
          0,
      createdAt: createdAt,
      description: description.isEmpty ? null : description,
      privacy: v['privacy'] as String?,
      drillType: v['drillType'] as String?,
      videoType: v['videoType'] as String?,
      thumbnailUrl: thumb.isEmpty ? null : thumb,
      uploadedById: uploadedById,
    );
  }

  /// One item from `GET /players/.../videos` or `data` from `POST /videos`.
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
    final likesRaw = json['likes'];
    final likesCount = _parseLikeCount(likesRaw, json['likesCount']);
    final likedIds = _parseLikeIds(likesRaw);
    DateTime createdAt = DateTime.now();
    final createdRaw = json['createdAt'];
    if (createdRaw != null) {
      createdAt = DateTime.tryParse(createdRaw.toString()) ?? createdAt;
    }

    final uploadedBy = json['uploadedBy'];
    final uploadedById = uploadedBy == null
        ? null
        : (uploadedBy is String ? uploadedBy : uploadedBy.toString());

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
      likes: likesCount,
      likedUserIds: likedIds,
      commentCount: 0,
      createdAt: createdAt,
      description: description.isEmpty ? null : description,
      privacy: json['privacy'] as String?,
      drillType: json['drillType'] as String?,
      videoType: json['videoType'] as String?,
      thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
      uploadedById: uploadedById,
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
