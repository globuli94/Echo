// lib/features/follow/presentation/bloc/follow_event.dart
//
// FollowEvent — sealed hierarchy of events for [FollowBloc].

import 'package:equatable/equatable.dart';

sealed class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object?> get props => [];
}

/// Initialises the follow status stream for [targetUid].
final class FollowStatusSubscribed extends FollowEvent {
  const FollowStatusSubscribed({
    required this.currentUid,
    required this.targetUid,
  });

  final String currentUid;
  final String targetUid;

  @override
  List<Object?> get props => [currentUid, targetUid];
}

/// Requests follow action.
final class FollowRequested extends FollowEvent {
  const FollowRequested({
    required this.currentUid,
    required this.targetUid,
  });

  final String currentUid;
  final String targetUid;

  @override
  List<Object?> get props => [currentUid, targetUid];
}

/// Requests unfollow action.
final class UnfollowRequested extends FollowEvent {
  const UnfollowRequested({
    required this.currentUid,
    required this.targetUid,
  });

  final String currentUid;
  final String targetUid;

  @override
  List<Object?> get props => [currentUid, targetUid];
}
