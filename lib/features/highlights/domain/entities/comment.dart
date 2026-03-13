class Comment {
  final String id;
  final String userId;
  final String username;
  final String? profileImage;
  final String text;
  final DateTime createdAt;
  final int likes;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImage,
    required this.text,
    required this.createdAt,
    this.likes = 0,
  });
}
