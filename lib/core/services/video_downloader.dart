import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

typedef DownloadProgressCallback = void Function(double progress);

class VideoDownloader {
  VideoDownloader({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> downloadToGallery(
    String url, {
    String? album,
    DownloadProgressCallback? onProgress,
  }) async {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw const VideoDownloadException('Permission denied');
      }
    }

    final tempDir = await getTemporaryDirectory();
    final filename = _fileNameFromUrl(url);
    final tempPath = '${tempDir.path}/$filename';
    final file = File(tempPath);
    if (await file.exists()) {
      await file.delete();
    }

    try {
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
      await Gal.putVideo(tempPath, album: album);
    } on DioException catch (e) {
      throw VideoDownloadException(
        e.message ?? 'Network error while downloading video',
      );
    } on GalException catch (e) {
      throw VideoDownloadException(e.type.message);
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final last = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return last.contains('.') ? last : '$last.mp4';
  }
}

class VideoDownloadException implements Exception {
  const VideoDownloadException(this.message);
  final String message;

  @override
  String toString() => message;
}
