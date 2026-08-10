import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

final class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
