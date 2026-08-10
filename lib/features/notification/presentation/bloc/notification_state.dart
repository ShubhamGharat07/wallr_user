import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final bool isRefreshing;

  const NotificationLoaded(this.notifications, {this.isRefreshing = false});

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    bool? isRefreshing,
  }) =>
      NotificationLoaded(
        notifications ?? this.notifications,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [notifications, isRefreshing];
}

final class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
