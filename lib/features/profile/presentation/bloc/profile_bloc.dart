// lib/features/profile/presentation/bloc/profile_bloc.dart
//
// ProfileBloc — manages loading and updating user profiles.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC that orchestrates all user profile operations.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required UserProfileRepository repository})
      : _repository = repository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
  }

  final UserProfileRepository _repository;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getUserProfile(event.uid);
      emit(ProfileLoaded(
        profile: profile,
        isOwner: event.uid == event.viewerUid,
      ));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(ProfileUpdating(profile: current.profile));
    try {
      await _repository.updateProfile(
        uid: event.uid,
        displayName: event.displayName,
        bio: event.bio,
      );
      final updated = await _repository.getUserProfile(event.uid);
      emit(ProfileLoaded(profile: updated, isOwner: current.isOwner));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  Future<void> _onAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(ProfileUpdating(profile: current.profile));
    try {
      final newUrl = await _repository.uploadAvatar(
        uid: event.uid,
        imagePath: event.imagePath,
      );
      final updatedProfile = current.profile.copyWith(avatarUrl: newUrl);
      emit(ProfileLoaded(profile: updatedProfile, isOwner: current.isOwner));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}
