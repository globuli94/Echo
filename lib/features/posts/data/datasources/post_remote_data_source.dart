// lib/features/posts/data/datasources/post_remote_data_source.dart
//
// PostRemoteDataSource — abstract interface and Firebase implementation
// for post data operations.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class PostRemoteDataSource {
  Stream<List<Map<String, dynamic>>> streamFeed();

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
}
