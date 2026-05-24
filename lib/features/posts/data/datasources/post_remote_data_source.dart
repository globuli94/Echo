// lib/features/posts/data/datasources/post_remote_data_source.dart
//
// PostRemoteDataSource — abstract interface and Firebase implementation
// for post data operations.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class PostRemoteDataSource {
  Stream<List<Map<String, dynamic>>> streamFeed();

  /// Fetches up to [limit] raw post documents ordered by `createdAt` DESC.
  ///
  /// If [before] is provided, only posts with `createdAt` strictly less than
  /// [before] are returned, enabling cursor-based pagination.
  Future<List<Map<String, dynamic>>> fetchFeedPage({
    DateTime? before,
    required int limit,
  });

  Future<void> createPost({
    required String postId,
    required String authorId,
    required String content,
    String? imageUrl,
  });

  Future<void> deletePost(String postId);

  Future<String> uploadPostImage({
    required String uid,
    required String postId,
    required String imagePath,
  });

  Future<void> deletePostImage({
    required String uid,
    required String postId,
  });

  Future<Map<String, dynamic>?> getAuthorProfile(String uid);

  /// Fetches up to [limit] raw post documents for the given [authorIds],
  /// ordered by `createdAt` DESC. Returns empty list if [authorIds] is empty.
  Future<List<Map<String, dynamic>>> fetchFollowedFeedPage({
    required List<String> authorIds,
    DateTime? before,
    required int limit,
  });

  /// Fetches up to [limit] raw post documents authored by [authorId],
  /// ordered by `createdAt` DESC.
  Future<List<Map<String, dynamic>>> fetchUserPosts({
    required String authorId,
    DateTime? before,
    required int limit,
  });

  /// Atomically increments likeCount on [postId] and creates the likes doc.
  Future<void> likePost({required String uid, required String postId});

  /// Atomically decrements likeCount on [postId] and deletes the likes doc.
  Future<void> unlikePost({required String uid, required String postId});

  /// Returns true if [uid] has liked [postId].
  Future<bool> isLiked({required String uid, required String postId});

  /// Streams whether [uid] has liked [postId].
  Stream<bool> streamIsLiked({required String uid, required String postId});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Stream<List<Map<String, dynamic>>> streamFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFeedPage({
    DateTime? before,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true);

    if (before != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(before),
      );
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<void> createPost({
    required String postId,
    required String authorId,
    required String content,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'likeCount': 0,
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }
    await _firestore.collection('posts').doc(postId).set(data);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  @override
  Future<String> uploadPostImage({
    required String uid,
    required String postId,
    required String imagePath,
  }) async {
    final ref = _storage.ref('posts/$uid/$postId');
    await ref.putFile(File(imagePath));
    return ref.getDownloadURL();
  }

  @override
  Future<void> deletePostImage({
    required String uid,
    required String postId,
  }) async {
    try {
      await _storage.ref('posts/$uid/$postId').delete();
    } catch (_) {
      // Image may not exist; ignore errors.
    }
  }

  @override
  Future<Map<String, dynamic>?> getAuthorProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFollowedFeedPage({
    required List<String> authorIds,
    DateTime? before,
    required int limit,
  }) async {
    if (authorIds.isEmpty) return [];

    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .where('authorId', whereIn: authorIds)
        .orderBy('createdAt', descending: true);

    if (before != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(before),
      );
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserPosts({
    required String authorId,
    DateTime? before,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true);

    if (before != null) {
      query = query.where(
        'createdAt',
        isLessThan: Timestamp.fromDate(before),
      );
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<void> likePost({
    required String uid,
    required String postId,
  }) async {
    final batch = _firestore.batch();
    final likeDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(postId);
    final postDoc = _firestore.collection('posts').doc(postId);

    batch.set(likeDoc, {'likedAt': FieldValue.serverTimestamp()});
    batch.update(postDoc, {'likeCount': FieldValue.increment(1)});
    await batch.commit();
  }

  @override
  Future<void> unlikePost({
    required String uid,
    required String postId,
  }) async {
    final batch = _firestore.batch();
    final likeDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(postId);
    final postDoc = _firestore.collection('posts').doc(postId);

    batch.delete(likeDoc);
    batch.update(postDoc, {'likeCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  @override
  Future<bool> isLiked({
    required String uid,
    required String postId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(postId)
        .get();
    return doc.exists;
  }

  @override
  Stream<bool> streamIsLiked({
    required String uid,
    required String postId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
