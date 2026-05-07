import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> fetchConversation({
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  });

  Future<MessageModel> postDirectMessage({
    required String receiverId,
    required String content,
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
  Future<List<MessageModel>> fetchConversation({
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.messagesWithUserPath(peerUserId),
      );
      final body = res.data;
      if (body == null) return [];
      final list = body['data'];
      if (list is! List) return [];
      return list
          .whereType<Object>()
          .map((e) => MessageModel.fromApiMap(
                Map<String, dynamic>.from(e as Map),
                peerUserId: peerUserId,
                currentUserId: currentUserId,
                selfDisplayName: selfDisplayName,
                peerDisplayName: peerDisplayName,
              ))
          .toList();
    } on DioException catch (e) {
      throw ChatApiException(_msgFromDio(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<MessageModel> postDirectMessage({
    required String receiverId,
    required String content,
    required String peerUserId,
    required String currentUserId,
    required String selfDisplayName,
    required String peerDisplayName,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.messages,
        data: <String, dynamic>{
          'receiverId': receiverId,
          'content': content,
        },
      );
      final body = res.data;
      Map<String, dynamic>? payload;
      if (body != null && body['data'] is Map) {
        payload = Map<String, dynamic>.from(body['data'] as Map);
      } else if (body != null && body['success'] == true) {
        payload = body;
      }
      if (payload == null) {
        throw const ChatApiException('Invalid response');
      }
      return MessageModel.fromApiMap(
        payload,
        peerUserId: peerUserId,
        currentUserId: currentUserId,
        selfDisplayName: selfDisplayName,
        peerDisplayName: peerDisplayName,
      );
    } on DioException catch (e) {
      throw ChatApiException(_msgFromDio(e), statusCode: e.response?.statusCode);
    }
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}
