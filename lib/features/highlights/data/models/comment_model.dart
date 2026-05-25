import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.userId,
    required super.username,
    super.profileImage,
    required super.text,
    required super.createdAt,
    super.likes,
    super.likedByMe,
    super.parentCommentId,
    super.replies,
    super.userRole,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'],
        userId: json['userId'],
        username: json['username'],
        profileImage: json['profileImage'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
        likes: json['likes'] ?? 0,
      );

  /// `GET/POST` video comments API shape.
  factory CommentModel.fromApiMap(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final userRaw = json['user'];
    var userId = '';
    // Empty when the populated user has no fullName — the UI hides the row
    // rather than show a misleading generic placeholder.
    var username = '';
    String? profileImage;
    String? userRole;
    if (userRaw is Map) {
      final u = Map<String, dynamic>.from(userRaw);
      userId = (u['_id'] ?? u['id'])?.toString() ?? '';
      // Treat empty strings as missing — Mongo populate sometimes returns
      // empty `fullName` for users that never set one.
      String? pick(dynamic v) {
        if (v is String && v.trim().isNotEmpty) return v.trim();
        return null;
      }
      username = pick(u['fullName']) ??
          pick(u['username']) ??
          pick(u['name']) ??
          '';
      profileImage = u['profileImageUrl'] as String? ?? u['profileImage'] as String?;
      userRole = u['role'] as String?;
    } else if (userRaw is String) {
      // Server returned the comment without populating the user (just an
      // ObjectId). Keep the id so other features can still resolve it.
      userId = userRaw;
    }

    final likesRaw = json['likes'];
    final likesCount = likesRaw is List
        ? likesRaw.length
        : (json['likesCount'] is int
            ? json['likesCount'] as int
            : int.tryParse(json['likesCount']?.toString() ?? '') ?? 0);
    final likedByMe = currentUserId != null &&
        likesRaw is List &&
        likesRaw.map((e) => e.toString()).contains(currentUserId);

    final parent = json['parentComment'];
    final parentCommentId = parent == null
        ? null
        : (parent is String ? parent : parent.toString());

    final createdRaw = json['createdAt'];
    final createdAt = createdRaw != null
        ? (DateTime.tryParse(createdRaw.toString()) ?? DateTime.now())
        : DateTime.now();

    final repliesRaw = json['replies'];
    final List<CommentModel> replies = [];
    if (repliesRaw is List) {
      for (final item in repliesRaw) {
        if (item is Map) {
          replies.add(
            CommentModel.fromApiMap(
              Map<String, dynamic>.from(item),
              currentUserId: currentUserId,
            ),
          );
        }
      }
    }

    return CommentModel(
      id: id,
      userId: userId,
      username: username,
      profileImage: profileImage,
      text: json['text'] as String? ?? '',
      createdAt: createdAt,
      likes: likesCount,
      likedByMe: likedByMe,
      parentCommentId: parentCommentId,
      replies: replies,
      userRole: userRole,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'profileImage': profileImage,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
      };
}
