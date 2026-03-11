import 'package:goal_connect/features/auth/domain/entities/user.dart';

class Highlight {
  final String id;
  final User player;
  final String videoUrl;
  final String caption;
  final int likes;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.player,
    required this.videoUrl,
    required this.caption,
    required this.likes,
    required this.createdAt,
  });
}
