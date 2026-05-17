import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

void _log(String msg, [Object? data]) {
  developer.log(data == null ? msg : '$msg $data', name: 'chat.http');
}

/// One entry in the response from `GET /messages` — a peer profile plus the
/// last message exchanged and the unread count for the current user.
class ConversationSummaryDto {
  final String peerUserId;
  final String? peerEmail;
  final String? peerRole;
  final String? peerStatus;
  final Map<String, dynamic> lastMessageRaw;
  final int unreadCount;

  const ConversationSummaryDto({
    required this.peerUserId,
    required this.peerEmail,
    required this.peerRole,
    required this.peerStatus,
    required this.lastMessageRaw,
    required this.unreadCount,
  });
}

abstract class ChatRemoteDataSource {
  /// `GET /messages` — list of conversations the current user has been a
  /// participant in. The backend returns the peer user object, the last
  /// message and an unread count per thread.
  Future<List<ConversationSummaryDto>> fetchConversationList();

  Future<List<MessageModel>> fetchConversation({
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static String _msgFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Could not complete request';
  }

  @override
  Future<List<ConversationSummaryDto>> fetchConversationList() async {
    const path = ApiConstants.messages;
    _log('GET $path');
    try {
      final res = await _dio.get<Map<String, dynamic>>(path);
      final body = res.data;
      if (body == null) {
        _log('GET $path empty body');
        return const [];
      }
      final list = body['data'];
      if (list is! List) {
        _log('GET $path unexpected shape', body.keys.toList());
        return const [];
      }
      final mapped = <ConversationSummaryDto>[];
      for (final entry in list) {
        if (entry is! Map) continue;
        final user = entry['user'];
        if (user is! Map) continue;
        final peerId = (user['_id'] ?? user['id'])?.toString();
        if (peerId == null || peerId.isEmpty) continue;
        final last = entry['lastMessage'];
        if (last is! Map) continue;
        final unread = entry['unreadCount'];
        mapped.add(ConversationSummaryDto(
          peerUserId: peerId,
          peerEmail: user['email']?.toString(),
          peerRole: user['role']?.toString(),
          peerStatus: user['status']?.toString(),
          lastMessageRaw: Map<String, dynamic>.from(last),
          unreadCount: unread is int
              ? unread
              : int.tryParse(unread?.toString() ?? '') ?? 0,
        ));
      }
      _log('GET $path ok', {'count': mapped.length});
      return mapped;
    } on DioException catch (e) {
      _log('GET $path failed', {
        'status': e.response?.statusCode,
        'body': e.response?.data,
      });
      throw ChatApiException(_msgFromDio(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<MessageModel>> fetchConversation({
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  }) async {
    final path = ApiConstants.messagesWithUserPath(peerUserId);
    _log('GET $path', {'me': currentUserId, 'peerName': peerDisplayName});
    try {
      final res = await _dio.get<Map<String, dynamic>>(path);
      final body = res.data;
      if (body == null) {
        _log('GET $path empty body');
        return [];
      }
      final list = body['data'];
      if (list is! List) {
        _log('GET $path unexpected shape', body.keys.toList());
        return [];
      }
      final mapped = list
          .whereType<Object>()
          .map((e) => MessageModel.fromApiMap(
                Map<String, dynamic>.from(e as Map),
                peerUserId: peerUserId,
                currentUserId: currentUserId,
                selfDisplayName: selfDisplayName,
                peerDisplayName: peerDisplayName,
              ))
          .toList();
      _log('GET $path ok', {'count': mapped.length});
      return mapped;
    } on DioException catch (e) {
      _log('GET $path failed', {
        'status': e.response?.statusCode,
        'body': e.response?.data,
      });
      throw ChatApiException(_msgFromDio(e), statusCode: e.response?.statusCode);
    }
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}
