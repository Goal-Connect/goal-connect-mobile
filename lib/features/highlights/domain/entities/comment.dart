class Comment {
  final String id;
  final String userId;
  final String username;
  final String? profileImage;
  final String text;
  final DateTime createdAt;
  /// Like count (API `likes` array length or `likesCount`).
  final int likes;
  final bool likedByMe;
  final String? parentCommentId;
  final List<Comment> replies;
  final String? userRole;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImage,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.likedByMe = false,
    this.parentCommentId,
    this.replies = const [],
    this.userRole,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImage,
    String? text,
    DateTime? createdAt,
    int? likes,
    bool? likedByMe,
    String? parentCommentId,
    List<Comment>? replies,
    String? userRole,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      userRole: userRole ?? this.userRole,
    );
  }
}
