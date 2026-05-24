// lib/features/follow/presentation/bloc/follow_bloc.dart
//
// FollowBloc — manages follow/unfollow state for a given target user.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/repositories/follow_repository.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  FollowBloc({
    required FollowRepository repository,
    NotificationRepository? notificationRepository,
  })  : _repository = repository,
        _notificationRepository = notificationRepository,
        super(const FollowInitial()) {
    on<FollowStatusSubscribed>(_onStatusSubscribed);
    on<FollowRequested>(_onFollowRequested);
    on<UnfollowRequested>(_onUnfollowRequested);
  }

  final FollowRepository _repository;
  final NotificationRepository? _notificationRepository;

  Future<void> _onStatusSubscribed(
    FollowStatusSubscribed event,
    Emitter<FollowState> emit,
  ) async {
    emit(const FollowLoading());
    await emit.forEach(
      _repository.streamFollowStatus(
        currentUid: event.currentUid,
        targetUid: event.targetUid,
      ),
      onData: (status) => FollowStatusLoaded(status: status),
      onError: (_, __) => const FollowFailure(error: 'Failed to load follow status'),
    );
  }

  Future<void> _onFollowRequested(
    FollowRequested event,
    Emitter<FollowState> emit,
  ) async {
    final current = state;
    final lastKnown = current is FollowStatusLoaded ? current.status : null;
    if (lastKnown != null) {
      emit(FollowActionInProgress(status: lastKnown));
    }
    try {
      await _repository.follow(
        currentUid: event.currentUid,
        targetUid: event.targetUid,
      );
      await _notificationRepository?.createFollowNotification(
        recipientUid: event.targetUid,
        actorUid: event.currentUid,
        actorDisplayName: event.actorDisplayName,
        actorAvatarUrl: event.actorAvatarUrl,
      );
      // Stream auto-updates via FollowStatusSubscribed — no manual emit needed.
    } catch (e) {
      emit(FollowFailure(
        error: e.toString(),
        lastKnownStatus: lastKnown,
      ));
    }
  }

  Future<void> _onUnfollowRequested(
    UnfollowRequested event,
    Emitter<FollowState> emit,
  ) async {
    final current = state;
    final lastKnown = current is FollowStatusLoaded ? current.status : null;
    if (lastKnown != null) {
      emit(FollowActionInProgress(status: lastKnown));
    }
    try {
      await _repository.unfollow(
        currentUid: event.currentUid,
        targetUid: event.targetUid,
      );
      // Stream auto-updates via FollowStatusSubscribed — no manual emit needed.
    } catch (e) {
      emit(FollowFailure(
        error: e.toString(),
        lastKnownStatus: lastKnown,
      ));
    }
  }
}
