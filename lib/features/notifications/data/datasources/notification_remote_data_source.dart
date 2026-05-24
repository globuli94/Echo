// lib/features/notifications/data/datasources/notification_remote_data_source.dart
//
// NotificationRemoteDataSource — abstract interface and Firebase implementation
// for notification data operations.

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationRemoteDataSource {
  /// Streams raw notification maps for [uid] ordered by createdAt DESC.
  Stream<List<Map<String, dynamic>>> streamNotifications({
    required String uid,
  });

  /// Updates the read field of a notification document to true.
  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  });

  /// Creates a like notification document under [recipientUid].
  /// No-op when [recipientUid] == [actorUid].
  Future<void> createLikeNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String postId,
  });

  /// Creates a follow notification document under [recipientUid].
  /// No-op when [recipientUid] == [actorUid].
  Future<void> createFollowNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Map<String, dynamic>>> streamNotifications({
    required String uid,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  @override
  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Future<void> createLikeNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String postId,
  }) async {
    if (recipientUid == actorUid) return;

    final collectionRef = _firestore
        .collection('users')
        .doc(recipientUid)
        .collection('notifications');

    final data = <String, dynamic>{
      'notificationId': '',
      'type': 'like',
      'actorUid': actorUid,
      'actorDisplayName': actorDisplayName,
      'postId': postId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (actorAvatarUrl != null) {
      data['actorAvatarUrl'] = actorAvatarUrl;
    }

    final docRef = await collectionRef.add(data);
    await docRef.update({'notificationId': docRef.id});
  }

  @override
  Future<void> createFollowNotification({
    required String recipientUid,
    required String actorUid,
    required String actorDisplayName,
    String? actorAvatarUrl,
  }) async {
    if (recipientUid == actorUid) return;

    final collectionRef = _firestore
        .collection('users')
        .doc(recipientUid)
        .collection('notifications');

    final data = <String, dynamic>{
      'notificationId': '',
      'type': 'follow',
      'actorUid': actorUid,
      'actorDisplayName': actorDisplayName,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (actorAvatarUrl != null) {
      data['actorAvatarUrl'] = actorAvatarUrl;
    }

    final docRef = await collectionRef.add(data);
    await docRef.update({'notificationId': docRef.id});
  }
}
