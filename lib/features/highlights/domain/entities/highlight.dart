class Highlight {
  final String id;
  final String playerId;
  final String videoUrl;
  final String caption;
  final int likes;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.playerId,
    required this.videoUrl,
    required this.caption,
    required this.likes,
    required this.createdAt,
  });
}
