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
  });
}
