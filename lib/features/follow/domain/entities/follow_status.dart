// lib/features/follow/domain/entities/follow_status.dart
//
// FollowStatus — domain entity representing the follow relationship between
// the current user and a target profile.

import 'package:equatable/equatable.dart';

/// Immutable domain entity that captures whether the authenticated user
/// currently follows a given target user.
class FollowStatus extends Equatable {
  const FollowStatus({required this.isFollowing, required this.targetUid});

  /// Whether the authenticated user follows [targetUid].
  final bool isFollowing;

  /// UID of the user whose follow status is being tracked.
  final String targetUid;

  @override
  List<Object?> get props => [isFollowing, targetUid];
}
