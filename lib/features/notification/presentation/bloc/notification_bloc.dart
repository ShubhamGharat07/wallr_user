import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/clear_notifications_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;
  final DeleteNotificationUseCase _deleteNotification;
  final ClearNotificationsUseCase _clearNotifications;

  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markAsRead,
    required DeleteNotificationUseCase deleteNotification,
    required ClearNotificationsUseCase clearNotifications,
  })  : _getNotifications = getNotifications,
        _markAsRead = markAsRead,
        _deleteNotification = deleteNotification,
        _clearNotifications = clearNotifications,
        super(const NotificationInitial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<NotificationsRefreshed>(_onNotificationsRefreshed);
    on<NotificationMarkReadRequested>(_onMarkReadRequested);
    on<NotificationDeleted>(_onDeleteRequested);
    on<NotificationsCleared>(_onClearAllRequested);
  }

  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await _getNotifications(const NoParams());
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onNotificationsRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const NotificationLoading());
    }

    final result = await _getNotifications(const NoParams());
    result.fold(
      (failure) {
        if (current is NotificationLoaded) {
          emit(current.copyWith(isRefreshing: false));
        } else {
          emit(NotificationError(failure.message));
        }
      },
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.notifications.map((n) {
        if (n.id == event.notificationId && !n.isRead) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(NotificationLoaded(updated, isRefreshing: current.isRefreshing));

      await _markAsRead(event.notificationId);
    }
  }

  Future<void> _onDeleteRequested(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final previous = current.notifications;
    final updated =
        previous.where((n) => n.id != event.notificationId).toList();
    emit(NotificationLoaded(updated, isRefreshing: current.isRefreshing));

    final result = await _deleteNotification(event.notificationId);
    result.fold(
      (_) => emit(NotificationLoaded(previous, isRefreshing: current.isRefreshing)),
      (_) {},
    );
  }

  Future<void> _onClearAllRequested(
    NotificationsCleared event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded || current.notifications.isEmpty) return;

    final previous = current.notifications;
    emit(const NotificationLoaded([], isRefreshing: false));

    final result = await _clearNotifications();
    result.fold(
      (_) => emit(NotificationLoaded(previous)),
      (_) {},
    );
  }
}
