import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Stream<List<NotificationModel>> watchNotifications();

  Future<void> markAsRead(String notificationId, String uid);

  Future<void> deleteNotification(String notificationId);

  Future<void> clearAllNotifications();

  Future<void> saveFcmToken(String uid, String token);
}

final class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _fetchOrdered();
    } catch (e) {
      throw ServerException(message: 'Failed to load notifications: $e');
    }
  }

  /// Orders by the timestamp field the backend actually writes (`sentTime`),
  /// falling back to other candidate fields, and finally to an un-ordered
  /// fetch sorted in memory — so a schema mismatch can never blank the list.
  Future<List<NotificationModel>> _fetchOrdered() async {
    for (final field in const ['sentTime', 'sentAt', 'createdAt']) {
      try {
        final snapshot = await _firestore
            .collection('notifications')
            .orderBy(field, descending: true)
            .limit(50)
            .get();
        return _toModels(snapshot);
      } catch (_) {
        // Field missing on server / mixed types — try the next candidate.
      }
    }

    final snapshot = await _firestore.collection('notifications').get();
    final models = _toModels(snapshot)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return models.take(50).toList();
  }

  List<NotificationModel> _toModels(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _firestore
        .collection('notifications')
        .snapshots()
        .map(_toModels);
  }

  @override
  Future<void> markAsRead(String notificationId, String uid) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'readBy.$uid': true,
      });
    } catch (e) {
      throw ServerException(message: 'Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete notification: $e');
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .limit(500)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to clear notifications: $e');
    }
  }

  @override
  Future<void> saveFcmToken(String uid, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to save FCM token: $e');
    }
  }
}
