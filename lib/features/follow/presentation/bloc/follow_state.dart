// lib/features/follow/presentation/bloc/follow_state.dart
//
// FollowState — sealed hierarchy of states emitted by [FollowBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/follow_status.dart';

sealed class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any status has been loaded.
final class FollowInitial extends FollowState {
  const FollowInitial();
}

/// Waiting for the initial follow status to arrive.
final class FollowLoading extends FollowState {
  const FollowLoading();
}

/// The follow status has been loaded successfully.
final class FollowStatusLoaded extends FollowState {
  const FollowStatusLoaded({required this.status});

  final FollowStatus status;

  @override
  List<Object?> get props => [status];
}

/// A follow or unfollow action is in progress.
///
/// [status] holds the last known status so the UI can show optimistic state.
final class FollowActionInProgress extends FollowState {
  const FollowActionInProgress({required this.status});

  /// The last known status — UI shows optimistic state.
  final FollowStatus status;

  @override
  List<Object?> get props => [status];
}

/// A follow or unfollow action failed.
final class FollowFailure extends FollowState {
  const FollowFailure({required this.error, this.lastKnownStatus});

  final String error;
  final FollowStatus? lastKnownStatus;

  @override
  List<Object?> get props => [error, lastKnownStatus];
}
