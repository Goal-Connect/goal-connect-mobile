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
    super.isMine,
    super.edited,
  });

  factory MessageModel.fromApiMap(
    Map<String, dynamic> json, {
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  }) {
    final rawSender = json['senderId'];
    final senderId = rawSender is Map
        ? (rawSender['_id'] ?? rawSender['id'] ?? '').toString()
        : (rawSender ?? '').toString();
    final rawReceiver = json['receiverId'];
    final receiverId = rawReceiver is Map
        ? (rawReceiver['_id'] ?? rawReceiver['id'])?.toString()
        : rawReceiver?.toString();
    final isMine = senderId.isNotEmpty && senderId == currentUserId;
    final rawId = json['_id'] ?? json['id'];
    final createdRaw = json['createdAt'];
    return MessageModel(
      id: rawId?.toString() ?? '',
      conversationId: peerUserId,
      senderId: senderId,
      receiverId: receiverId,
      senderName: isMine ? selfDisplayName : peerDisplayName,
      text: (json['content'] ?? json['text'] ?? '').toString(),
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
      isMine: isMine,
      edited: json['edited'] == true || json['isEdited'] == true,
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
