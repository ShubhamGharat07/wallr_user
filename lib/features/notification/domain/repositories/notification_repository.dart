import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> clearAllNotifications();
  Stream<int> unreadCountStream();
}
