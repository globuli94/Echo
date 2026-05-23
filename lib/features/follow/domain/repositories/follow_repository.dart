// lib/features/follow/domain/repositories/follow_repository.dart
//
// FollowRepository — abstract interface for follow/unfollow operations.

import '../entities/follow_status.dart';

abstract class FollowRepository {
  /// Returns the current follow status for [currentUid] → [targetUid].
  Future<FollowStatus> getFollowStatus({
    required String currentUid,
    required String targetUid,
  });

  /// Streams the follow status for [currentUid] → [targetUid].
  Stream<FollowStatus> streamFollowStatus({
    required String currentUid,
    required String targetUid,
  });

  /// Follows [targetUid] as [currentUid].
  ///
  /// Atomically:
  /// 1. Creates `users/{currentUid}/following/{targetUid}` with `followedAt`
  ///    (server timestamp) and `targetUid`.
  /// 2. Increments `followerCount` on `users/{targetUid}`.
  /// 3. Increments `followingCount` on `users/{currentUid}`.
  Future<void> follow({
    required String currentUid,
    required String targetUid,
  });

  /// Unfollows [targetUid] as [currentUid].
  ///
  /// Atomically:
  /// 1. Deletes `users/{currentUid}/following/{targetUid}`.
  /// 2. Decrements `followerCount` on `users/{targetUid}` (floor 0).
  /// 3. Decrements `followingCount` on `users/{currentUid}` (floor 0).
  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  });

  /// Returns all UIDs that [uid] currently follows.
  Future<List<String>> getFollowingUids({required String uid});
}
