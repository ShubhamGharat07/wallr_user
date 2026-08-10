import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final FirebaseAuth _auth;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required FirebaseAuth auth,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _auth = auth;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    if (_uid == null) return Left(UnauthenticatedFailure());

    try {
      final models = await _remoteDataSource.getNotifications();
      final entities =
          models.map((m) => m.toEntity(currentUid: _uid!)).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    if (_uid == null) return Left(UnauthenticatedFailure());

    try {
      await _remoteDataSource.markAsRead(notificationId, _uid!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    if (_uid == null) return Left(UnauthenticatedFailure());

    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    if (_uid == null) return Left(UnauthenticatedFailure());

    try {
      await _remoteDataSource.clearAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<int> unreadCountStream() {
    if (_uid == null) return const Stream.empty();
    return _remoteDataSource.watchNotifications().map(
      (notifications) {
        final uid = _uid!;
        return notifications
            .where((n) => !n.readBy.containsKey(uid))
            .length;
      },
    );
  }
}
