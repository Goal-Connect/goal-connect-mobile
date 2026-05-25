import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';

abstract class NotificationsRepository {
  /// `GET /notifications` filtered to broadcast announcements, newest first.
  Future<Either<Failure, List<Announcement>>> getBroadcasts();

  /// `PUT /notifications/{id}/read` — mark a notification as read.
  /// Same endpoint is used to dismiss a broadcast banner.
  Future<Either<Failure, void>> markRead(String notificationId);
}
