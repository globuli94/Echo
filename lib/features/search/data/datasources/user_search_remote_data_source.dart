// lib/features/search/data/datasources/user_search_remote_data_source.dart
//
// UserSearchRemoteDataSource — Firestore-backed data source for user search.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../profile/domain/entities/user_profile.dart';

/// Contract for the user-search remote data source.
abstract interface class UserSearchRemoteDataSource {
  /// Fetches up to 20 users whose [displayName] starts with [query].
  Future<List<UserProfile>> searchUsers({required String query});
}

/// Firestore implementation of [UserSearchRemoteDataSource].
///
/// Executes a prefix range query on the `displayName` field using Firestore's
/// automatic single-field index.
class UserSearchRemoteDataSourceImpl implements UserSearchRemoteDataSource {
  /// Creates a [UserSearchRemoteDataSourceImpl] with the given [firestore]
  /// instance.
  const UserSearchRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<UserProfile>> searchUsers({required String query}) async {
    final snap = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: '$query\uF8FF')
        .orderBy('displayName')
        .limit(20)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return UserProfile(
        uid: data['uid'] as String? ?? doc.id,
        displayName: data['displayName'] as String? ?? '',
        bio: data['bio'] as String? ?? '',
        avatarUrl: data['avatarUrl'] as String?,
        followerCount: data['followerCount'] as int? ?? 0,
        followingCount: data['followingCount'] as int? ?? 0,
        postCount: data['postCount'] as int? ?? 0,
      );
    }).toList();
  }
}
