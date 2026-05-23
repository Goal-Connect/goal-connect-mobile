import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs Dio traffic with [debugPrint]. Disabled in release builds only ([kReleaseMode]).
///
/// Register after [AuthInterceptor] so headers reflect the attached Bearer token
/// (token value is redacted in logs).
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      final b = StringBuffer()
        ..writeln('┌── API REQUEST ─────────────────────────────────')
        ..writeln('│ ${options.method} ${options.uri}')
        ..writeln(
          '│ connectTimeout: ${options.connectTimeout}, '
          'receiveTimeout: ${options.receiveTimeout}, '
          'sendTimeout: ${options.sendTimeout}',
        );
      if (options.queryParameters.isNotEmpty) {
        b.writeln('│ queryParameters: ${options.queryParameters}');
      }
      b.writeln('│ headers: ${_sanitizeHeaders(options.headers)}');
      if (options.extra.isNotEmpty) {
        b.writeln('│ extra: ${options.extra}');
      }
      if (options.data != null) {
        b.writeln('│ body:\n${_formatPayload(options.data)}');
      }
      b.writeln('└────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      final req = response.requestOptions;
      final b = StringBuffer()
        ..writeln('┌── API RESPONSE ────────────────────────────────')
        ..writeln(
          '│ statusCode: ${response.statusCode} '
          '${response.statusMessage ?? ''}'.trimRight(),
        )
        ..writeln('│ ${req.method} ${req.uri}')
        ..writeln('│ responseHeaders: ${response.headers.map}')
        ..writeln('│ data:\n${_formatPayload(response.data)}')
        ..writeln('└────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      final b = StringBuffer()
        ..writeln('┌── API ERROR ───────────────────────────────────')
        ..writeln('│ dioErrorType: ${err.type}')
        ..writeln('│ message: ${err.message}')
        ..writeln(
          '│ ${err.requestOptions.method} ${err.requestOptions.uri}',
        );
      final res = err.response;
      if (res != null) {
        b
          ..writeln('│ statusCode: ${res.statusCode} ${res.statusMessage ?? ''}')
          ..writeln('│ responseHeaders: ${res.headers.map}')
          ..writeln('│ responseData:\n${_formatPayload(res.data)}');
      } else {
        b.writeln('│ (no response object — network / timeout / cancel)');
      }
      b.writeln('└────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(err);
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    for (final e in headers.entries) {
      if (e.key.toLowerCase() == 'authorization') {
        out[e.key] = _redactAuth(e.value);
      } else {
        out[e.key] = e.value;
      }
    }
    return out;
  }

  static String _redactAuth(Object? value) {
    final s = value?.toString() ?? '';
    if (s.length > 14 && s.startsWith('Bearer ')) {
      return 'Bearer <redacted len=${s.length - 7}>';
    }
    return '<redacted>';
  }

  static String _formatPayload(dynamic data) {
    if (data is FormData) {
      final lines = <String>[];
      for (final e in data.fields) {
        lines.add('  field ${e.key}: ${e.value}');
      }
      for (final e in data.files) {
        final f = e.value;
        lines.add('  file ${e.key}: filename=${f.filename}');
      }
      return lines.isEmpty ? '  (empty FormData)' : lines.join('\n');
    }
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  
}
