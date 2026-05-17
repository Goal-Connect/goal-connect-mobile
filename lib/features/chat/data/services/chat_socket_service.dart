import 'dart:async';
import 'dart:developer' as developer;

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_token_local_datasource.dart';

void _log(String msg, [Object? data]) {
  developer.log(data == null ? msg : '$msg $data', name: 'chat.socket');
}

/// Socket.IO client for DM.
///
/// Connects to [ApiConstants.socketBaseUrl] with the JWT in the handshake auth.
///
/// Client → Server:
///   `message:send`, `conversation:history`, `message:edit`, `message:delete`,
///   `message:read`, `typing:start`, `typing:stop`.
/// Server → Client:
///   `connection:success`, `message:sent`, `message:received`, `message:edited`,
///   `message:deleted`, `message:read`, `typing:start`, `typing:stop`.
class ChatSocketService {
  ChatSocketService({required AuthTokenLocalDataSource tokens}) : _tokens = tokens;

  final AuthTokenLocalDataSource _tokens;

  io.Socket? _socket;

  final _messageReceived = StreamController<Map<String, dynamic>>.broadcast();
  final _messageSent = StreamController<Map<String, dynamic>>.broadcast();
  final _messageEdited = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeleted = StreamController<Map<String, dynamic>>.broadcast();
  final _historyReceived = StreamController<List<dynamic>>.broadcast();
  final _connectionState = StreamController<bool>.broadcast();
  final _typingStart = StreamController<String>.broadcast();
  final _typingStop = StreamController<String>.broadcast();
  final _messagesRead = StreamController<MessagesReadPayload>.broadcast();

  Stream<Map<String, dynamic>> get onMessageReceived => _messageReceived.stream;
  Stream<Map<String, dynamic>> get onMessageSent => _messageSent.stream;
  Stream<Map<String, dynamic>> get onMessageEdited => _messageEdited.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _messageDeleted.stream;
  Stream<List<dynamic>> get onConversationHistory => _historyReceived.stream;
  Stream<bool> get onConnectionStateChanged => _connectionState.stream;

  /// Emits the `fromUserId` of the peer who started typing.
  Stream<String> get onTypingStart => _typingStart.stream;

  /// Emits the `fromUserId` of the peer who stopped typing.
  Stream<String> get onTypingStop => _typingStop.stream;

  /// Emits when one of *our* messages is marked read by a peer.
  Stream<MessagesReadPayload> get onMessagesRead => _messagesRead.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      _log('connect aborted: no token in storage');
      await disconnect();
      return;
    }

    await disconnect();

    final base = ApiConstants.socketBaseUrl;
    _log('connect()', {
      'url': base,
      'transports': ['websocket'],
      'tokenLen': token.length,
      'tokenPreview':
          token.length > 12 ? '${token.substring(0, 12)}…' : token,
    });
    _socket = io.io(
      base,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(8)
          .setReconnectionDelay(2000)
          .setAuth({'token': token})
          .build(),
    );

    // Lifecycle
    _socket!
      ..on('connect', (_) {
        _log('connect', {
          'sid': _socket?.id,
          'url': base,
          'transport': _socket?.io.engine?.transport?.name,
        });
        _connectionState.add(true);
      })
      ..on('connection:success', (data) {
        _log('server connection:success', data);
      })
      ..on('disconnect', (reason) {
        _log('disconnect', {'reason': reason});
        _connectionState.add(false);
      })
      ..on('connect_error', (e) {
        _log('connect_error', {
          'type': e.runtimeType.toString(),
          'message': e?.toString(),
        });
      })
      ..on('error', (e) {
        _log('error', {
          'type': e.runtimeType.toString(),
          'message': e?.toString(),
        });
      })
      ..on('reconnect_attempt', (n) => _log('reconnect_attempt', {'n': n}))
      ..on('reconnect', (n) => _log('reconnect', {'attempt': n}))
      ..on('reconnect_error', (e) => _log('reconnect_error', e?.toString()))
      ..on('reconnect_failed', (_) => _log('reconnect_failed'))
      // Known business events
      ..on('message:received',
          _onJsonEvent('message:received', _messageReceived.add))
      ..on('message:sent',
          _onJsonEvent('message:sent', _messageSent.add))
      ..on('message:edited',
          _onJsonEvent('message:edited', _messageEdited.add))
      ..on('message:deleted',
          _onJsonEvent('message:deleted', _messageDeleted.add))
      ..on('message:read', (data) {
        _log('recv message:read', data);
        final parsed = MessagesReadPayload._tryParse(data);
        if (parsed == null) {
          _log('recv message:read could not parse, ignored', data);
        } else {
          _messagesRead.add(parsed);
        }
      })
      ..on('typing:start', (data) {
        final id = _extractFromUserId(data);
        _log('recv typing:start', {'fromUserId': id, 'raw': data});
        if (id != null) _typingStart.add(id);
      })
      ..on('typing:stop', (data) {
        final id = _extractFromUserId(data);
        _log('recv typing:stop', {'fromUserId': id, 'raw': data});
        if (id != null) _typingStop.add(id);
      })
      ..on('conversation:history', (data) {
        _log('recv conversation:history',
            data is List ? {'count': data.length} : data);
        if (data is List) _historyReceived.add(data);
      });

    // Catch-all: anything the server sends that we don't subscribe to
    // explicitly still gets logged. Helpful when debugging server-side
    // event-name drift.
    _socket!.onAny((event, data) {
      // Filter out the known ones we already log above to avoid noise.
      const known = {
        'connect',
        'connection:success',
        'disconnect',
        'connect_error',
        'error',
        'reconnect',
        'reconnect_attempt',
        'reconnect_error',
        'reconnect_failed',
        'message:received',
        'message:sent',
        'message:edited',
        'message:deleted',
        'message:read',
        'typing:start',
        'typing:stop',
        'conversation:history',
      };
      if (known.contains(event)) return;
      _log('recv (unhandled) $event', data);
    });

    _socket!.connect();
  }

  void Function(dynamic) _onJsonEvent(
    String name,
    void Function(Map<String, dynamic>) emit,
  ) {
    return (dynamic data) {
      _log('recv $name', data);
      if (data is Map) {
        emit(Map<String, dynamic>.from(data));
      }
    };
  }

  String? _extractFromUserId(dynamic data) {
    if (data is Map) {
      final v = data['fromUserId'] ?? data['userId'] ?? data['from'];
      if (v != null) return v.toString();
    }
    return null;
  }

  /// Fire-and-forget send. The server echoes the canonical message via
  /// `message:sent` (to us) and `message:received` (to the peer).
  void emitSend({required String toUserId, required String content}) {
    final payload = {'toUserId': toUserId, 'content': content};
    if (!isConnected) {
      _log('emit message:send DROPPED (not connected)', {
        'connected': isConnected,
        'sid': _socket?.id,
        'payload': payload,
      });
      return;
    }
    _log('emit message:send', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('message:send', payload);
  }

  /// Ack-based send. Resolves with the server's response payload (whatever the
  /// backend acks with), or `null` if no response within [timeout] / no socket.
  Future<Map<String, dynamic>?> emitSendWithAck({
    required String toUserId,
    required String content,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final payload = {'toUserId': toUserId, 'content': content};
    final socket = _socket;
    if (socket == null || !socket.connected) {
      _log('emit message:send (ack) DROPPED (not connected)', {
        'connected': socket?.connected,
        'sid': socket?.id,
        'payload': payload,
      });
      return null;
    }
    _log('emit message:send (ack)',
        {'sid': socket.id, 'timeoutMs': timeout.inMilliseconds, 'payload': payload});
    final completer = Completer<Map<String, dynamic>?>();
    socket.emitWithAck(
      'message:send',
      payload,
      ack: (dynamic resp) {
        _log('ack message:send', {
          'type': resp.runtimeType.toString(),
          'response': resp,
        });
        if (completer.isCompleted) return;
        if (resp is Map) {
          completer.complete(Map<String, dynamic>.from(resp));
        } else {
          completer.complete(null);
        }
      },
    );
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _log('ack message:send TIMED OUT (no server response)',
            {'after': '${timeout.inMilliseconds}ms', 'payload': payload});
        return null;
      },
    );
  }

  /// Request history over socket. The app uses HTTP GET as primary; this is
  /// available for live sync after reconnect.
  void requestHistory({required String withUserId, int? limit}) {
    final payload = {
      'withUserId': withUserId,
      if (limit != null) 'limit': limit,
    };
    if (!isConnected) {
      _log('emit conversation:history DROPPED (not connected)',
          {'payload': payload});
      return;
    }
    _log('emit conversation:history', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('conversation:history', payload);
  }

  void emitEdit({required String messageId, required String newContent}) {
    final payload = {'messageId': messageId, 'newContent': newContent};
    if (!isConnected) {
      _log('emit message:edit DROPPED (not connected)', {'payload': payload});
      return;
    }
    _log('emit message:edit', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('message:edit', payload);
  }

  void emitDelete({required String messageId}) {
    final payload = {'messageId': messageId};
    if (!isConnected) {
      _log('emit message:delete DROPPED (not connected)', {'payload': payload});
      return;
    }
    _log('emit message:delete', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('message:delete', payload);
  }

  /// Mark every message from [withUserId] as read.
  Future<List<String>?> markRead({required String withUserId}) async {
    final payload = {'withUserId': withUserId};
    final socket = _socket;
    if (socket == null || !socket.connected) {
      _log('emit message:read DROPPED (not connected)', {'payload': payload});
      return null;
    }
    _log('emit message:read', {'sid': socket.id, 'payload': payload});
    final completer = Completer<List<String>?>();
    socket.emitWithAck(
      'message:read',
      payload,
      ack: (dynamic resp) {
        _log('ack message:read', {
          'type': resp.runtimeType.toString(),
          'response': resp,
        });
        if (completer.isCompleted) return;
        if (resp is Map && resp['messageIds'] is List) {
          completer.complete(
            (resp['messageIds'] as List).map((e) => e.toString()).toList(),
          );
        } else {
          completer.complete(null);
        }
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _log('ack message:read TIMED OUT', {'payload': payload});
        return null;
      },
    );
  }

  void emitTypingStart({required String toUserId}) {
    final payload = {'toUserId': toUserId};
    if (!isConnected) {
      _log('emit typing:start DROPPED (not connected)', {'payload': payload});
      return;
    }
    _log('emit typing:start', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('typing:start', payload);
  }

  void emitTypingStop({required String toUserId}) {
    final payload = {'toUserId': toUserId};
    if (!isConnected) {
      _log('emit typing:stop DROPPED (not connected)', {'payload': payload});
      return;
    }
    _log('emit typing:stop', {'sid': _socket?.id, 'payload': payload});
    _socket?.emit('typing:stop', payload);
  }

  Future<void> disconnect() async {
    if (_socket != null) _log('disconnect requested');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageReceived.close();
    _messageSent.close();
    _messageEdited.close();
    _messageDeleted.close();
    _historyReceived.close();
    _connectionState.close();
    _typingStart.close();
    _typingStop.close();
    _messagesRead.close();
  }
}

/// Payload for the server's `message:read` event:
/// `{ messageIds: [...], by: '<userId>' }`.
class MessagesReadPayload {
  final List<String> messageIds;
  final String by;

  const MessagesReadPayload({required this.messageIds, required this.by});

  static MessagesReadPayload? _tryParse(dynamic data) {
    if (data is! Map) return null;
    final ids = data['messageIds'];
    final by = data['by'];
    if (ids is! List || by == null) return null;
    return MessagesReadPayload(
      messageIds: ids.map((e) => e.toString()).toList(),
      by: by.toString(),
    );
  }
}
