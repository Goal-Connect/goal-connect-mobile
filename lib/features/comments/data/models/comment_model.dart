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
