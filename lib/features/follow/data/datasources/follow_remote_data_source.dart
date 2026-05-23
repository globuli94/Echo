// lib/features/follow/data/datasources/follow_remote_data_source.dart
//
// FollowRemoteDataSource — abstract interface and Firebase implementation
// for follow/unfollow data operations.

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FollowRemoteDataSource {
  Future<bool> isFollowing({
    required String currentUid,
    required String targetUid,
  });

  Stream<bool> streamIsFollowing({
    required String currentUid,
    required String targetUid,
  });

  Future<void> follow({
    required String currentUid,
    required String targetUid,
  });

  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  });

  Future<List<String>> getFollowingUids({required String uid});

  /// Returns the UIDs of all users who follow [targetUid] via a Firestore
  /// collection-group query on `following` where `targetUid == targetUid`.
  Future<List<String>> getFollowerUids({required String targetUid});
}

class FollowRemoteDataSourceImpl implements FollowRemoteDataSource {
  FollowRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<bool> isFollowing({
    required String currentUid,
    required String targetUid,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();
    return doc.exists;
  }

  @override
  Stream<bool> streamIsFollowing({
    required String currentUid,
    required String targetUid,
  }) {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Future<void> follow({
    required String currentUid,
    required String targetUid,
  }) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);
    final targetUserRef = _firestore.collection('users').doc(targetUid);
    final currentUserRef = _firestore.collection('users').doc(currentUid);

    batch.set(followingRef, {
      'followedAt': FieldValue.serverTimestamp(),
      'targetUid': targetUid,
    });
    batch.update(targetUserRef, {'followerCount': FieldValue.increment(1)});
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});

    await batch.commit();
  }

  @override
  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  }) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);
    final targetUserRef = _firestore.collection('users').doc(targetUid);
    final currentUserRef = _firestore.collection('users').doc(currentUid);

    batch.delete(followingRef);
    batch.update(targetUserRef, {'followerCount': FieldValue.increment(-1)});
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  @override
  Future<List<String>> getFollowingUids({required String uid}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<List<String>> getFollowerUids({required String targetUid}) async {
    final snapshot = await _firestore
        .collectionGroup('following')
        .where('targetUid', isEqualTo: targetUid)
        .get();
    // Each doc path is users/{followerUid}/following/{targetUid}.
    // The followerUid is the grandparent document id.
    return snapshot.docs
        .map((doc) => doc.reference.parent.parent!.id)
        .toList();
  }
}
