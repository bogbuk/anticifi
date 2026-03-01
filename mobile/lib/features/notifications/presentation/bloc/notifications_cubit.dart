import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        emit(NotificationsLoaded(
          notifications: currentState.notifications,
          unreadCount: count,
        ));
      } else {
        emit(NotificationsLoaded(
          notifications: const [],
          unreadCount: count,
        ));
      }
    } catch (_) {
      // Silently fail for badge count
    }
  }
}
