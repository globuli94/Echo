// lib/features/notifications/presentation/bloc/notification_event.dart
//
// NotificationEvent — sealed hierarchy of events for [NotificationBloc].

import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribes to the notification stream for [uid].
final class NotificationsSubscribed extends NotificationEvent {
  const NotificationsSubscribed({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// Requests that a single notification be marked as read.
final class NotificationReadRequested extends NotificationEvent {
  const NotificationReadRequested({
    required this.uid,
    required this.notificationId,
  });

  final String uid;
  final String notificationId;

  @override
  List<Object?> get props => [uid, notificationId];
}
