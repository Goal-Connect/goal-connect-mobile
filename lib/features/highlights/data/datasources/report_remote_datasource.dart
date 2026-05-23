import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';

class ReportApiException implements Exception {
  final String message;

  ReportApiException(this.message);

  @override
  String toString() => message;
}

abstract class ReportRemoteDataSource {
  Future<void> reportVideo({
    required String targetId,
    required String description,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Something went wrong';
  }

  @override
  Future<void> reportVideo({
    required String targetId,
    required String description,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.reports,
        data: <String, dynamic>{
          'targetType': 'video',
          'targetId': targetId,
          'reason': 'inappropriate_content',
          'description': description,
          'reportType': 'VIDEO_VIOLATION',
        },
      );
    } on DioException catch (e) {
      throw ReportApiException(_messageFromDio(e));
    }
  }
}
