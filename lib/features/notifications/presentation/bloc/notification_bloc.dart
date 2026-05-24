// lib/features/notifications/presentation/bloc/notification_bloc.dart
//
// NotificationBloc — manages the notification stream and mark-as-read actions.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<NotificationsSubscribed>(_onSubscribed);
    on<NotificationReadRequested>(_onReadRequested);
  }

  final NotificationRepository _repository;

  Future<void> _onSubscribed(
    NotificationsSubscribed event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationsLoading());
    await emit.forEach(
      _repository.streamNotifications(uid: event.uid),
      onData: (notifications) => NotificationsLoaded(
        notifications: notifications,
      ),
      onError: (_, __) => const NotificationsError(
        message: 'Failed to load notifications',
      ),
    );
  }

  Future<void> _onReadRequested(
    NotificationReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(
        uid: event.uid,
        notificationId: event.notificationId,
      );
      // Stream auto-updates the state; no manual emit needed.
    } catch (_) {
      // Silently ignore mark-as-read failures; the stream will reflect reality.
    }
  }
}
