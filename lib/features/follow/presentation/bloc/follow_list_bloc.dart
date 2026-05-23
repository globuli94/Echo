// lib/features/follow/presentation/bloc/follow_list_bloc.dart
//
// FollowListBloc — loads the list of followers or following users for a profile.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/follow_repository.dart';
import 'follow_list_event.dart';
import 'follow_list_state.dart';

/// BLoC that loads a paginated list of [UserProfile]s for the followers or
/// following screens. Provided at route level — one instance per screen visit.
class FollowListBloc extends Bloc<FollowListEvent, FollowListState> {
  FollowListBloc({
    required FollowRepository followRepository,
    required UserProfileRepository profileRepository,
  })  : _followRepository = followRepository,
        _profileRepository = profileRepository,
        super(const FollowListInitial()) {
    on<FollowersRequested>(_onFollowersRequested);
    on<FollowingRequested>(_onFollowingRequested);
  }

  final FollowRepository _followRepository;
  final UserProfileRepository _profileRepository;

  Future<void> _onFollowersRequested(
    FollowersRequested event,
    Emitter<FollowListState> emit,
  ) async {
    emit(const FollowListLoading());
    try {
      final uids =
          await _followRepository.getFollowerUids(targetUid: event.targetUid);
      final profiles = await Future.wait(
        uids.map((uid) => _profileRepository.getUserProfile(uid)),
      );
      emit(FollowListLoaded(users: profiles));
    } catch (e) {
      emit(FollowListError(message: e.toString()));
    }
  }

  Future<void> _onFollowingRequested(
    FollowingRequested event,
    Emitter<FollowListState> emit,
  ) async {
    emit(const FollowListLoading());
    try {
      final uids =
          await _followRepository.getFollowingUids(uid: event.profileUid);
      final profiles = await Future.wait(
        uids.map((uid) => _profileRepository.getUserProfile(uid)),
      );
      emit(FollowListLoaded(users: profiles));
    } catch (e) {
      emit(FollowListError(message: e.toString()));
    }
  }
}
