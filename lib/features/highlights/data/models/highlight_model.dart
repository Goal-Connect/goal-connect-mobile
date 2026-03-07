import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../../domain/entities/highlight.dart';

class HighlightModel extends Highlight {
  HighlightModel({
    required super.id,
    required super.player,
    required super.videoUrl,
    required super.caption,
    required super.likes,
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
