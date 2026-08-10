import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

final class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }
}