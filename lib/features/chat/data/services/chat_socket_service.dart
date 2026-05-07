import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_token_local_datasource.dart';

/// Socket.IO client for DM — connects with JWT; listens for server push events.
class ChatSocketService {
  ChatSocketService({required AuthTokenLocalDataSource tokens}) : _tokens = tokens;

  final AuthTokenLocalDataSource _tokens;

  io.Socket? _socket;

  final _messageReceived = StreamController<Map<String, dynamic>>.broadcast();
  final _messageEdited = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeleted = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessageReceived => _messageReceived.stream;

  Stream<Map<String, dynamic>> get onMessageEdited => _messageEdited.stream;

  Stream<Map<String, dynamic>> get onMessageDeleted => _messageDeleted.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      await disconnect();
      return;
    }

    await disconnect();

    final base = ApiConstants.socketBaseUrl;
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

    _socket!
      ..on('message:received', _onJsonEvent(_messageReceived.add))
      ..on('message:edited', _onJsonEvent(_messageEdited.add))
      ..on('message:deleted', _onJsonEvent(_messageDeleted.add))
      ..on('connect_error', (_) {})
      ..on('error', (_) {})
      ..connect();
  }

  void Function(dynamic) _onJsonEvent(void Function(Map<String, dynamic>) emit) {
    return (dynamic data) {
      if (data is Map) {
        emit(Map<String, dynamic>.from(data));
      }
    };
  }

  /// Emit `message:send` — preferred path when socket is up (HTTP remains fallback in repository).
  void emitSend({required String toUserId, required String content}) {
    if (!isConnected) return;
    _socket?.emit('message:send', {
      'toUserId': toUserId,
      'content': content,
    });
  }

  /// Request history over socket (optional; app uses HTTP GET as primary).
  void requestHistory({required String withUserId, int? limit}) {
    if (!isConnected) return;
    _socket?.emit('conversation:history', {
      'withUserId': withUserId,
      if (limit != null) 'limit': limit,
    });
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageReceived.close();
    _messageEdited.close();
    _messageDeleted.close();
  }
}
