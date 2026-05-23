// lib/features/follow/presentation/bloc/follow_list_event.dart
//
// FollowListEvent — events for [FollowListBloc].

import 'package:equatable/equatable.dart';

sealed class FollowListEvent extends Equatable {
  const FollowListEvent();

  @override
  List<Object?> get props => [];
}

/// Requests loading users who follow [targetUid].
final class FollowersRequested extends FollowListEvent {
  const FollowersRequested({required this.targetUid});

  final String targetUid;

  @override
  List<Object?> get props => [targetUid];
}

/// Requests loading users that [profileUid] follows.
final class FollowingRequested extends FollowListEvent {
  const FollowingRequested({required this.profileUid});

  final String profileUid;

  @override
  List<Object?> get props => [profileUid];
}
