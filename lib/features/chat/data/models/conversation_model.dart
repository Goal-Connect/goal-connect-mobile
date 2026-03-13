import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    super.participantImage,
    required super.participantRole,
    required super.lastMessage,
    required super.updatedAt,
    super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'],
        participantId: json['participantId'],
        participantName: json['participantName'],
        participantImage: json['participantImage'],
        participantRole: json['participantRole'],
        lastMessage: json['lastMessage'],
        updatedAt: DateTime.parse(json['updatedAt']),
        unreadCount: json['unreadCount'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantId': participantId,
        'participantName': participantName,
        'participantImage': participantImage,
        'participantRole': participantRole,
        'lastMessage': lastMessage,
        'updatedAt': updatedAt.toIso8601String(),
        'unreadCount': unreadCount,
      };
}
