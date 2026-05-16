import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../../../auth/data/datasources/auth_user_local_datasource.dart';
import '../../../profile/domain/repositories/player_profile_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/conversation_local_datasource.dart';
import '../models/message_model.dart';
import '../services/chat_socket_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ConversationLocalDataSource conversationLocal,
    required AuthUserLocalDataSource userLocal,
    required ChatSocketService socketService,
    required PlayerProfileRepository playerProfileRepository,
  })  : _remote = remoteDataSource,
        _local = conversationLocal,
        _userLocal = userLocal,
        _socket = socketService,
        _playerProfileRepository = playerProfileRepository;

  final ChatRemoteDataSource _remote;
  final ConversationLocalDataSource _local;
  final AuthUserLocalDataSource _userLocal;
  final ChatSocketService _socket;
  final PlayerProfileRepository _playerProfileRepository;

  /// In-memory cache so we only hit `/players/:id` once per peer per session
  /// while resolving names for inbound socket messages.
  final Map<String, String> _peerNameMemo = {};

  Future<String> _peerDisplayName(String peerUserId) async {
    final threads = await _local.loadThreads();
    for (final t in threads) {
      if (t.id == peerUserId && t.participantName.isNotEmpty) {
        return t.participantName;
      }
    }
    final memo = _peerNameMemo[peerUserId];
    if (memo != null) return memo;

    // Try resolving against the players endpoint; the peer may be a player we
    // haven't cached yet. For scouts (no equivalent public endpoint here) the
    // lookup will fail and we fall back to a friendly label.
    final lookup = await _playerProfileRepository.getPlayerProfile(
      playerId: peerUserId,
    );
    return lookup.fold(
      (_) {
        _peerNameMemo[peerUserId] = 'Scout';
        return 'Scout';
      },
      (player) {
        final name = player.username.trim();
        final resolved = name.isEmpty ? 'Player' : name;
        _peerNameMemo[peerUserId] = resolved;
        return resolved;
      },
    );
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final threads = await _local.loadThreads();
      return Right(threads);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String peerUserId) async {
    final user = await _userLocal.readCachedUser();
    if (user == null) {
      return Left(AuthFailure());
    }
    final peerName = await _peerDisplayName(peerUserId);
    try {
      final list = await _remote.fetchConversation(
        peerUserId: peerUserId,
        currentUserId: user.id,
        selfDisplayName: user.username,
        peerDisplayName: peerName,
      );
      return Right(list);
    } on ChatApiException catch (e) {
      return Left(ChatFailure(e.message));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required Conversation peerThread,
    required String text,
  }) async {
    final user = await _userLocal.readCachedUser();
    if (user == null) {
      return Left(AuthFailure());
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Left(ChatFailure('Message is empty'));
    }

    final peerUserId = peerThread.id;
    final peerName = peerThread.participantName;

    try {
      MessageModel sent;
      if (_socket.isConnected) {
        _socket.emitSend(toUserId: peerUserId, content: trimmed);
        sent = MessageModel(
          id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: peerUserId,
          senderId: user.id,
          receiverId: peerUserId,
          senderName: user.username,
          text: trimmed,
          createdAt: DateTime.now(),
          isRead: false,
          isMine: true,
        );
      } else {
        sent = await _remote.postDirectMessage(
          receiverId: peerUserId,
          content: trimmed,
          peerUserId: peerUserId,
          currentUserId: user.id,
          selfDisplayName: user.username,
          peerDisplayName: peerName,
        );
      }

      await _local.upsertThread(
        peerUserId: peerUserId,
        lastMessage: trimmed,
        updatedAt: sent.createdAt,
        participantName: peerThread.participantName,
        participantImage: peerThread.participantImage,
        participantRole: peerThread.participantRole,
      );

      return Right(sent);
    } on ChatApiException catch (e) {
      return Left(ChatFailure(e.message));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Message? messageFromSocketPayload(
    Map<String, dynamic> raw, {
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
    required String peerUserId,
  }) {
    try {
      return MessageModel.fromApiMap(
        raw,
        peerUserId: peerUserId,
        currentUserId: currentUserId,
        selfDisplayName: selfDisplayName,
        peerDisplayName: peerDisplayName,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> touchThreadFromIncomingMessage(Message message, String myUserId) async {
    final sender = message.senderId;
    final receiver = message.receiverId;
    String? peer;
    if (sender == myUserId) {
      peer = receiver;
    } else if (receiver != null && receiver == myUserId) {
      peer = sender;
    } else {
      return;
    }
    if (peer == null || peer.isEmpty) return;

    await _local.upsertThread(
      peerUserId: peer,
      lastMessage: message.text,
      updatedAt: message.createdAt,
      unreadDelta: sender == myUserId ? 0 : 1,
    );
  }

  @override
  Future<String> resolvePeerDisplayName(String peerUserId) =>
      _peerDisplayName(peerUserId);
}
