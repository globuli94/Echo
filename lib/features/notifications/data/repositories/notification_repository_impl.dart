// lib/features/notifications/data/repositories/notification_repository_impl.dart
//
// NotificationRepositoryImpl — concrete implementation of [NotificationRepository].

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final NotificationRemoteDataSource _dataSource;

  @override
  Stream<List<AppNotification>> streamNotifications({required String uid}) {
    return _dataSource
        .streamNotifications(uid: uid)
        .map((docs) => docs.map(_mapToNotification).toList());
  }

  @override
  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) {
    return _dataSource.markAsRead(uid: uid, notificationId: notificationId);
  }

  @override
  Future<void> createLikeNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String postId,
  }) {
    return _dataSource.createLikeNotification(
      recipientUid: recipientUid,
      actorUid: actorUid,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      postId: postId,
    );
  }

  @override
  Future<void> createFollowNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
  }) {
    return _dataSource.createFollowNotification(
      recipientUid: recipientUid,
      actorUid: actorUid,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
    );
  }

  AppNotification _mapToNotification(Map<String, dynamic> doc) {
    final createdAtRaw = doc['createdAt'];
    final DateTime createdAt;
    if (createdAtRaw != null) {
      createdAt = (createdAtRaw as dynamic).toDate() as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    return AppNotification(
      notificationId: doc['notificationId'] as String? ??
          doc['id'] as String? ??
          '',
      type: doc['type'] as String? ?? '',
      actorUid: doc['actorUid'] as String? ?? '',
      actorDisplayName: doc['actorDisplayName'] as String? ?? '',
      actorAvatarUrl: doc['actorAvatarUrl'] as String?,
      postId: doc['postId'] as String?,
      read: doc['read'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}
