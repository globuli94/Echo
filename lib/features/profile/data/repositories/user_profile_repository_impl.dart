// lib/features/profile/data/repositories/user_profile_repository_impl.dart
//
// UserProfileRepositoryImpl — maps raw Firestore data to domain entities and
// delegates all Firebase calls to ProfileRemoteDataSource.

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Firebase-backed implementation of [UserProfileRepository].
class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({required ProfileRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final ProfileRemoteDataSource _dataSource;

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final data = await _dataSource.getUserProfile(uid);
    return UserProfile(
      uid: uid,
      displayName: (data['displayName'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      postCount: (data['postCount'] as num?)?.toInt() ?? 0,
      followerCount: (data['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
  }) =>
      _dataSource.updateProfile(uid: uid, displayName: displayName, bio: bio);

  @override
  Future<String> uploadAvatar({
    required String uid,
    required String imagePath,
  }) =>
      _dataSource.uploadAvatar(uid: uid, imagePath: imagePath);
}
