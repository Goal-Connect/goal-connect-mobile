import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';
import 'package:goal_connect/features/notifications/domain/repositories/notifications_repository.dart';

class GetBroadcastsUsecase {
  final NotificationsRepository repository;

  GetBroadcastsUsecase(this.repository);

  Future<Either<Failure, List<Announcement>>> call() =>
      repository.getBroadcasts();
}
