import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

final class ClearNotificationsUseCase {
  final NotificationRepository _repository;

  ClearNotificationsUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.clearAllNotifications();
  }
}