// lib/features/notifications/domain/entities/app_notification.dart
//
// AppNotification — pure domain entity representing a single notification.

import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.notificationId,
    required this.type,
    required this.actorUid,
    required this.actorDisplayName,
    this.actorAvatarUrl,
    this.postId,
    required this.read,
    required this.createdAt,
  });

  /// Unique identifier of this notification document.
  final String notificationId;

  /// Type of notification: 'like' or 'follow'.
  final String type;

  /// UID of the user who performed the action.
  final String actorUid;

  /// Display name of the actor.
  final String actorDisplayName;

  /// Avatar URL of the actor, or null if not set.
  final String? actorAvatarUrl;

  /// The post ID, set only for 'like' notifications.
  final String? postId;

  /// Whether the recipient has read this notification.
  final bool read;

  /// When the notification was created.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        notificationId,
        type,
        actorUid,
        actorDisplayName,
        actorAvatarUrl,
        postId,
        read,
        createdAt,
      ];
}
