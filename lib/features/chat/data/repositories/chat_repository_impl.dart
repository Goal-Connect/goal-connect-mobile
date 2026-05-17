import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../../../core/error/fialures.dart';
import '../../../auth/data/datasources/auth_user_local_datasource.dart';
import '../../../profile/domain/repositories/player_profile_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_socket_service.dart';

void _log(String message, [Object? data]) {
  developer.log(
    data == null ? message : '$message $data',
    name: 'chat.repo',
  );
}

/// Source of truth is the server. The conversation list comes from
/// `GET /messages`, thread history from `GET /messages/{userId}`, and every
/// send / edit / delete / typing / read goes over Socket.IO. We keep an
/// in-memory map of threads for snappy UI updates between server fetches;
/// nothing is persisted to disk.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required AuthUserLocalDataSource userLocal,
    required ChatSocketService socketService,
    required PlayerProfileRepository playerProfileRepository,
  })  : _remote = remoteDataSource,
        _userLocal = userLocal,
        _socket = socketService,
        _playerProfileRepository = playerProfileRepository;

  final ChatRemoteDataSource _remote;
  final AuthUserLocalDataSource _userLocal;
  final ChatSocketService _socket;
  final PlayerProfileRepository _playerProfileRepository;

  /// peerUserId → conversation. Rebuilt per session; never persisted.
  final Map<String, ConversationModel> _threads = {};

  /// peerUserId → cached resolved display name (avoid re-hitting /players/:id).
  final Map<String, String> _nameMemo = {};

  /// peerUserId → cached profile image URL.
  final Map<String, String?> _imageMemo = {};

  Future<_PeerInfo> _peerInfo(String peerUserId) async {
    final existing = _threads[peerUserId];
    if (existing != null && existing.participantName.isNotEmpty) {
      return _PeerInfo(
        name: existing.participantName,
        image: existing.participantImage,
        role: existing.participantRole,
      );
    }
    if (_nameMemo.containsKey(peerUserId)) {
      return _PeerInfo(
        name: _nameMemo[peerUserId]!,
        image: _imageMemo[peerUserId],
        role: 'member',
      );
    }
    _log('resolving peer profile', peerUserId);
    final lookup = await _playerProfileRepository.getPlayerProfile(
      playerId: peerUserId,
    );
    return lookup.fold(
      (failure) {
        _log('peer lookup failed, defaulting to scout label', peerUserId);
        _nameMemo[peerUserId] = 'Scout';
        _imageMemo[peerUserId] = null;
        return const _PeerInfo(name: 'Scout', image: null, role: 'scout');
      },
      (player) {
        final raw = player.username.trim();
        final name = raw.isEmpty ? 'Player' : raw;
        final image = player.profileImage.isEmpty ? null : player.profileImage;
        _nameMemo[peerUserId] = name;
        _imageMemo[peerUserId] = image;
        _log('resolved peer', {'id': peerUserId, 'name': name});
        return _PeerInfo(name: name, image: image, role: 'player');
      },
    );
  }

  void _upsert({
    required String peerUserId,
    required String lastMessage,
    required DateTime updatedAt,
    required _PeerInfo info,
    int unreadDelta = 0,
  }) {
    final existing = _threads[peerUserId];
    final unread = ((existing?.unreadCount ?? 0) + unreadDelta).clamp(0, 999);
    _threads[peerUserId] = ConversationModel(
      id: peerUserId,
      participantId: peerUserId,
      participantName: info.name,
      participantImage: info.image ?? existing?.participantImage,
      participantRole: info.role,
      lastMessage: lastMessage,
      updatedAt: updatedAt,
      unreadCount: unread,
    );
  }

  List<Conversation> _sortedThreads() {
    final list = _threads.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    final user = await _userLocal.readCachedUser();
    if (user == null) {
      _log('getConversations aborted: no cached user');
      return Left(AuthFailure());
    }
    try {
      _log('GET /messages');
      final dtos = await _remote.fetchConversationList();
      final infos = await Future.wait(
        dtos.map(_peerInfoFromDto),
        eagerError: false,
      );
      for (var i = 0; i < dtos.length; i++) {
        final dto = dtos[i];
        final info = infos[i];
        final last = dto.lastMessageRaw;
        final content = (last['content'] ?? last['text'] ?? '').toString();
        final createdRaw = last['createdAt'];
        final createdAt = createdRaw != null
            ? DateTime.tryParse(createdRaw.toString()) ?? DateTime.now()
            : DateTime.now();
        _threads[dto.peerUserId] = ConversationModel(
          id: dto.peerUserId,
          participantId: dto.peerUserId,
          participantName: info.name,
          participantImage: info.image,
          participantRole: info.role,
          lastMessage: content,
          updatedAt: createdAt,
          unreadCount: dto.unreadCount,
        );
      }
      // Drop any in-memory threads the server no longer reports (e.g. deleted
      // conversations). Threads only ever appear via `GET /messages` or via
      // a thread visit / inbound socket, so this stays consistent.
      final serverIds = dtos.map((d) => d.peerUserId).toSet();
      _threads.removeWhere(
        (id, t) => !serverIds.contains(id) && t.lastMessage.isEmpty,
      );
      _log('GET /messages ok', {'count': _threads.length});
      return Right(_sortedThreads());
    } on ChatApiException catch (e) {
      _log('GET /messages failed', {
        'status': e.statusCode,
        'message': e.message,
      });
      return Left(ChatFailure(e.message));
    } catch (e, st) {
      _log('GET /messages crashed', e);
      developer.log('stack', name: 'chat.repo', error: e, stackTrace: st);
      return Left(ServerFailure());
    }
  }

  /// Build peer info from a `GET /messages` entry. For players (and unknown
  /// roles — chats may exist with users whose `role` is absent in the list
  /// payload) try `GET /players/:id` to get the real fullName + image. For
  /// everyone else, derive a friendly name from email.
  Future<_PeerInfo> _peerInfoFromDto(ConversationSummaryDto dto) async {
    final role = (dto.peerRole ?? '').toLowerCase();
    final email = dto.peerEmail ?? '';
    final emailName = email.contains('@') ? email.split('@').first : '';

    if (role == 'player' || role.isEmpty) {
      final lookup = await _playerProfileRepository.getPlayerProfile(
        playerId: dto.peerUserId,
      );
      final resolved = lookup.fold<_PeerInfo?>(
        (_) => null,
        (player) {
          final raw = player.username.trim();
          final image =
              player.profileImage.isEmpty ? null : player.profileImage;
          if (raw.isEmpty) return null;
          _nameMemo[dto.peerUserId] = raw;
          _imageMemo[dto.peerUserId] = image;
          return _PeerInfo(
            name: raw,
            image: image,
            role: role.isEmpty ? 'player' : role,
          );
        },
      );
      if (resolved != null) return resolved;
    }

    // Fallback path: no player profile (scout / coach / agent / 404).
    final display = emailName.isNotEmpty
        ? emailName
        : (role.isEmpty ? 'User' : _capitalize(role));
    _nameMemo[dto.peerUserId] = display;
    _imageMemo[dto.peerUserId] = null;
    return _PeerInfo(
      name: display,
      image: null,
      role: role.isEmpty ? 'member' : role,
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Future<Either<Failure, List<Message>>> getMessages(String peerUserId) async {
    final user = await _userLocal.readCachedUser();
    if (user == null) {
      _log('getMessages aborted: no cached user');
      return Left(AuthFailure());
    }
    final info = await _peerInfo(peerUserId);
    try {
      _log('GET /messages/$peerUserId', {'me': user.id});
      final list = await _remote.fetchConversation(
        peerUserId: peerUserId,
        currentUserId: user.id,
        selfDisplayName: user.username,
        peerDisplayName: info.name,
      );
      _log('GET /messages/$peerUserId ok', {'count': list.length});

      if (list.isNotEmpty) {
        final last = list.last;
        _upsert(
          peerUserId: peerUserId,
          lastMessage: last.text,
          updatedAt: last.createdAt,
          info: info,
        );
      } else if (!_threads.containsKey(peerUserId)) {
        _upsert(
          peerUserId: peerUserId,
          lastMessage: '',
          updatedAt: DateTime.now(),
          info: info,
        );
      }
      return Right(list);
    } on ChatApiException catch (e) {
      _log('GET /messages/$peerUserId failed', {
        'status': e.statusCode,
        'message': e.message,
      });
      return Left(ChatFailure(e.message));
    } catch (e, st) {
      _log('GET /messages/$peerUserId crashed', e);
      developer.log('stack', name: 'chat.repo', error: e, stackTrace: st);
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required Conversation peerThread,
    required String text,
  }) async {
    final user = await _userLocal.readCachedUser();
    if (user == null) return Left(AuthFailure());
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Left(ChatFailure('Message is empty'));

    final peerUserId = peerThread.id;
    final info = _PeerInfo(
      name: peerThread.participantName,
      image: peerThread.participantImage,
      role: peerThread.participantRole,
    );

    if (!_socket.isConnected) {
      _log('send aborted: socket disconnected');
      return Left(ChatFailure('Disconnected. Reconnecting…'));
    }

    try {
      _log('socket emit message:send (ack)',
          {'to': peerUserId, 'len': trimmed.length});
      final ack = await _socket.emitSendWithAck(
        toUserId: peerUserId,
        content: trimmed,
      );
      final payload = _extractMessagePayload(ack);
      MessageModel sent;
      if (payload != null) {
        sent = MessageModel.fromApiMap(
          payload,
          peerUserId: peerUserId,
          currentUserId: user.id,
          selfDisplayName: user.username,
          peerDisplayName: info.name,
        );
      } else {
        // No ack from the server — keep an optimistic placeholder. The
        // `message:sent` socket event will replace it when it arrives.
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
      }

      _upsert(
        peerUserId: peerUserId,
        lastMessage: trimmed,
        updatedAt: sent.createdAt,
        info: info,
      );
      return Right(sent);
    } catch (e, st) {
      _log('send crashed', e);
      developer.log('stack', name: 'chat.repo', error: e, stackTrace: st);
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
    } catch (e) {
      _log('messageFromSocketPayload failed', e);
      return null;
    }
  }

  @override
  Future<void> touchThreadFromIncomingMessage(
    Message message,
    String myUserId,
  ) async {
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

    final info = await _peerInfo(peer);
    _upsert(
      peerUserId: peer,
      lastMessage: message.text,
      updatedAt: message.createdAt,
      info: info,
      unreadDelta: sender == myUserId ? 0 : 1,
    );
    _log('touch thread from inbound', {
      'peer': peer,
      'fromMe': sender == myUserId,
    });
  }

  @override
  Future<String> resolvePeerDisplayName(String peerUserId) async {
    final info = await _peerInfo(peerUserId);
    return info.name;
  }

  /// The backend ack for `message:send` may come back in a few shapes:
  /// the message map directly, `{ data: {...} }`, or `{ message: {...} }`.
  /// Return whichever wrapped map looks like a valid message.
  Map<String, dynamic>? _extractMessagePayload(Map<String, dynamic>? ack) {
    if (ack == null) return null;
    bool looksLikeMessage(Map<String, dynamic> m) =>
        (m['_id'] ?? m['id']) != null || m['content'] != null;
    if (looksLikeMessage(ack)) return ack;
    for (final key in const ['data', 'message', 'payload']) {
      final v = ack[key];
      if (v is Map) {
        final m = Map<String, dynamic>.from(v);
        if (looksLikeMessage(m)) return m;
      }
    }
    return null;
  }
}

class _PeerInfo {
  final String name;
  final String? image;
  final String role;

  const _PeerInfo({required this.name, required this.image, required this.role});
}
