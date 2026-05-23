// lib/features/profile/domain/repositories/user_profile_repository.dart
//
// UserProfileRepository — abstract interface for profile operations.

import '../entities/user_profile.dart';

/// Abstract contract for user profile operations.
abstract class UserProfileRepository {
  /// Fetches the profile for [uid].
  Future<UserProfile> getUserProfile(String uid);

  /// Updates [displayName] and [bio] for the owner.
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
  });

  /// Uploads [imagePath] to Storage at `avatars/{uid}`, then updates
  /// `users/{uid}.avatarUrl` with the resulting download URL.
  /// Returns the new download URL.
  Future<String> uploadAvatar({
    required String uid,
    required String imagePath,
  });
}
