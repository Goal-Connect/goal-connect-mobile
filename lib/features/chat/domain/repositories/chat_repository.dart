import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// [peerUserId] is the other participant's auth user id (`GET /messages/:userId`).
  Future<Either<Failure, List<Message>>> getMessages(String peerUserId);

  Future<Either<Failure, Message>> sendMessage({
    required Conversation peerThread,
    required String text,
  });

  /// Maps a Socket.IO `message:received` payload; returns null if invalid.
  Message? messageFromSocketPayload(
    Map<String, dynamic> raw, {
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
    required String peerUserId,
  });

  Future<void> touchThreadFromIncomingMessage(Message message, String myUserId);

  Future<String> resolvePeerDisplayName(String peerUserId);
}
