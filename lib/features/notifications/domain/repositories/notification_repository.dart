// lib/features/notifications/domain/repositories/notification_repository.dart
//
// NotificationRepository — abstract interface for notification operations.

import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// Streams notifications for [uid] ordered by createdAt DESC.
  Stream<List<AppNotification>> streamNotifications({required String uid});

  /// Marks a single notification as read.
  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  });

  /// Creates a 'like' notification for [recipientUid].
  /// No-op when [recipientUid] == [actorUid].
  Future<void> createLikeNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String postId,
  });

  /// Creates a 'follow' notification for [recipientUid].
  /// No-op when [recipientUid] == [actorUid].
  Future<void> createFollowNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
  });
}
