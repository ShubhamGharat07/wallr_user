import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

final class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String type;
  final String? targetId;
  final String? targetRoute;
  final DateTime sentAt;
  final Map<String, bool> readBy;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.type = 'announcement',
    this.targetId,
    this.targetRoute,
    required this.sentAt,
    this.readBy = const {},
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      type: data['type'] as String? ?? 'announcement',
      targetId: data['targetId'] as String?,
      targetRoute: data['targetRoute'] as String?,
      sentAt: _resolveTimestamp(data),
      readBy: data['readBy'] != null
          ? Map<String, bool>.from(data['readBy'] as Map)
          : {},
    );
  }

  /// Backend notification documents use `sentTime` (and `createdAt`/`updatedAt`),
  /// older variants may use `sentAt`. Resolve whichever exists, tolerantly.
  static DateTime _resolveTimestamp(Map<String, dynamic> data) {
    for (final field in const ['sentAt', 'sentTime', 'createdAt', 'updatedAt']) {
      final value = data[field];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': type,
      'targetId': targetId,
      'targetRoute': targetRoute,
      'sentAt': Timestamp.fromDate(sentAt),
      'readBy': readBy,
    };
  }

  NotificationEntity toEntity({required String currentUid}) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: type,
      targetId: targetId,
      targetRoute: targetRoute,
      sentAt: sentAt,
      isRead: readBy.containsKey(currentUid),
    );
  }
}
