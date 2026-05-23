// lib/features/profile/data/datasources/profile_remote_data_source.dart
//
// ProfileRemoteDataSource — wraps Firestore and Firebase Storage for profile
// operations.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Abstract contract for remote profile data operations.
abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile(String uid);

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
  });

  Future<String> uploadAvatar({
    required String uid,
    required String imagePath,
  });
}

/// Firebase-backed implementation of [ProfileRemoteDataSource].
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (data == null) {
      throw Exception('User profile not found for uid: $uid');
    }
    return data;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
  }) =>
      _firestore.collection('users').doc(uid).update({
        'displayName': displayName,
        'bio': bio,
      });

  @override
  Future<String> uploadAvatar({
    required String uid,
    required String imagePath,
  }) async {
    final ref = _storage.ref('avatars/$uid');
    await ref.putFile(File(imagePath));
    final url = await ref.getDownloadURL();
    await _firestore.collection('users').doc(uid).update({'avatarUrl': url});
    return url;
  }
}
