// lib/features/profile/presentation/bloc/profile_event.dart
//
// ProfileEvent — sealed hierarchy of events handled by [ProfileBloc].

import 'package:equatable/equatable.dart';

/// Base class for all profile events.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Requests loading a user's profile.
///
/// [uid] identifies whose profile to load. [viewerUid] is used to determine
/// ownership (isOwner = uid == viewerUid).
final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({
    required this.uid,
    required this.viewerUid,
  });

  final String uid;
  final String viewerUid;

  @override
  List<Object?> get props => [uid, viewerUid];
}

/// Requests updating the authenticated user's display name and bio.
final class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
    required this.uid,
    required this.displayName,
    required this.bio,
  });

  final String uid;
  final String displayName;
  final String bio;

  @override
  List<Object?> get props => [uid, displayName, bio];
}

/// Requests uploading a new avatar image.
final class ProfileAvatarUploadRequested extends ProfileEvent {
  const ProfileAvatarUploadRequested({
    required this.uid,
    required this.imagePath,
  });

  final String uid;
  final String imagePath;

  @override
  List<Object?> get props => [uid, imagePath];
}
