import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();
}

final class NotificationsRefreshed extends NotificationEvent {
  const NotificationsRefreshed();
}

final class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationDeleted extends NotificationEvent {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationsCleared extends NotificationEvent {
  const NotificationsCleared();
}

final class NotificationsSubscriptionStarted extends NotificationEvent {
  const NotificationsSubscriptionStarted();
}
