import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

/// Persists this device's FCM token under the signed-in user's Firestore doc
/// so the backend can push to it. Without a stored token no push can ever
/// reach the device, so notifications would only ever appear in-app.
final class SaveFcmTokenUseCase {
  final NotificationRepository _repository;

  SaveFcmTokenUseCase(this._repository);

  Future<Either<Failure, void>> call(String token) {
    return _repository.saveFcmToken(token);
  }
}
