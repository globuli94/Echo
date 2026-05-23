// lib/features/profile/domain/entities/user_profile.dart
//
// UserProfile — domain entity representing a user's public profile.

import 'package:equatable/equatable.dart';

/// Immutable domain entity for a user's public profile.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.postCount,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final String uid;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;

  /// Returns a copy with the given fields replaced.
  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    int? followerCount,
    int? followingCount,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      postCount: postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  List<Object?> get props =>
      [uid, displayName, bio, avatarUrl, postCount, followerCount, followingCount];
}
