import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUsecase {
  final NotificationsRepository repository;

  MarkNotificationReadUsecase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) =>
      repository.markRead(notificationId);
}
