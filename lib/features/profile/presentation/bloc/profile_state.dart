// lib/features/profile/presentation/bloc/profile_state.dart
//
// ProfileState — sealed hierarchy of states emitted by [ProfileBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

/// Base class for all profile states.
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any profile has been loaded.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Emitted while a profile fetch is in progress.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Emitted when a profile has been successfully loaded.
final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profile, required this.isOwner});

  final UserProfile profile;

  /// Whether the viewer is the owner of this profile.
  final bool isOwner;

  @override
  List<Object?> get props => [profile, isOwner];
}

/// Emitted during a profile update while still showing existing data.
final class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Emitted when a profile operation fails.
final class ProfileFailure extends ProfileState {
  const ProfileFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
