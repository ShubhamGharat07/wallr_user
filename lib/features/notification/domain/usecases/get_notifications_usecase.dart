import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

final class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) {
    return _repository.getNotifications();
  }
}
