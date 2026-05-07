import 'package:goal_connect/features/auth/domain/entities/user.dart';

class Highlight {
  final String id;
  final User player;
  final String videoUrl;
  /// Display title (maps to API `title`).
  final String caption;
  final int likes;
  final List<String> likedUserIds;
  final int commentCount;
  final DateTime createdAt;
  final String? description;
  final String? privacy;
  final String? drillType;
  final String? videoType;
  final String? thumbnailUrl;
  final String? uploadedById;

  Highlight({
    required this.id,
    required this.player,
    required this.videoUrl,
    required this.caption,
    required this.likes,
    this.likedUserIds = const [],
    this.commentCount = 0,
    required this.createdAt,
    this.description,
    this.privacy,
    this.drillType,
    this.videoType,
    this.thumbnailUrl,
    this.uploadedById,
  });
}
