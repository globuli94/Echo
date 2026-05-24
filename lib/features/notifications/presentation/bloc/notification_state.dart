// lib/features/notifications/presentation/bloc/notification_state.dart
//
// NotificationState — sealed hierarchy of states emitted by [NotificationBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any subscription.
final class NotificationsInitial extends NotificationState {
  const NotificationsInitial();
}

/// Emitted while waiting for the first stream event.
final class NotificationsLoading extends NotificationState {
  const NotificationsLoading();
}

/// Emitted when notifications have been loaded from the stream.
final class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded({required this.notifications});

  final List<AppNotification> notifications;

  /// Number of unread notifications.
  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  List<Object?> get props => [notifications];
}

/// Emitted when the notification stream fails.
final class NotificationsError extends NotificationState {
  const NotificationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
