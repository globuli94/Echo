// lib/features/follow/presentation/bloc/follow_list_state.dart
//
// FollowListState — states emitted by [FollowListBloc].

import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/user_profile.dart';

sealed class FollowListState extends Equatable {
  const FollowListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any request.
final class FollowListInitial extends FollowListState {
  const FollowListInitial();
}

/// List is being loaded.
final class FollowListLoading extends FollowListState {
  const FollowListLoading();
}

/// List loaded successfully.
final class FollowListLoaded extends FollowListState {
  const FollowListLoaded({required this.users});

  final List<UserProfile> users;

  @override
  List<Object?> get props => [users];
}

/// An error occurred while loading.
final class FollowListError extends FollowListState {
  const FollowListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
