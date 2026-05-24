class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final bool isMine;
  final bool edited;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.isMine = false,
    this.edited = false,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? text,
    DateTime? createdAt,
    bool? isRead,
    bool? isMine,
    bool? edited,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isMine: isMine ?? this.isMine,
      edited: edited ?? this.edited,
    );
  }
}
