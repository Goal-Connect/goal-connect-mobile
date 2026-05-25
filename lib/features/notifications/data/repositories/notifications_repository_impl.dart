import 'package:dartz/dartz.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';
import 'package:goal_connect/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Announcement>>> getBroadcasts() async {
    try {
      final list = await remoteDataSource.listBroadcasts();
      return Right(list);
    } on NotificationsApiException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String notificationId) async {
    try {
      await remoteDataSource.markRead(notificationId);
      return const Right(null);
    } on NotificationsApiException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
