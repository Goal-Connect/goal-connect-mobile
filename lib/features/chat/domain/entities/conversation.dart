class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantImage;
  final String participantRole;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantImage,
    required this.participantRole,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });
}
