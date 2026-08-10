import 'package:equatable/equatable.dart';

final class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String type;
  final String? targetId;
  final String? targetRoute;
  final DateTime sentAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.type = 'announcement',
    this.targetId,
    this.targetRoute,
    required this.sentAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    String? type,
    String? targetId,
    String? targetRoute,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      targetRoute: targetRoute ?? this.targetRoute,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, imageUrl, type, targetId, targetRoute, sentAt, isRead];
}
