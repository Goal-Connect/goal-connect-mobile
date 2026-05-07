import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.receiverId,
    required super.senderName,
    required super.text,
    required super.createdAt,
    super.isRead,
  });

  factory MessageModel.fromApiMap(
    Map<String, dynamic> json, {
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  }) {
    final senderId = (json['senderId'] ?? '').toString();
    final isMine = senderId == currentUserId;
    final rawId = json['_id'] ?? json['id'];
    final createdRaw = json['createdAt'];
    return MessageModel(
      id: rawId?.toString() ?? '',
      conversationId: peerUserId,
      senderId: senderId,
      receiverId: json['receiverId']?.toString(),
      senderName: isMine ? selfDisplayName : peerDisplayName,
      text: (json['content'] ?? json['text'] ?? '').toString(),
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        receiverId: json['receiverId'] as String?,
        senderName: json['senderName'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'senderName': senderName,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };
}
