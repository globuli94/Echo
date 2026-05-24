// lib/features/posts/presentation/bloc/like_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import 'like_event.dart';
import 'like_state.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState> {
  LikeBloc({required PostRepository repository})
      : _repository = repository,
        super(const LikeInitial()) {
    on<LikeStatusFetched>(_onLikeStatusFetched);
    on<LikeToggleRequested>(_onLikeToggleRequested);
  }

  final PostRepository _repository;

  Future<void> _onLikeStatusFetched(
    LikeStatusFetched event,
    Emitter<LikeState> emit,
  ) async {
    emit(const LikeLoading());
    try {
      final isLiked = await _repository.isPostLikedBy(
        postId: event.postId,
        uid: event.currentUserId,
      );
      emit(LikeLoaded(isLiked: isLiked, likeCount: event.initialCount));
    } catch (e) {
      emit(LikeError(error: e.toString()));
    }
  }

  Future<void> _onLikeToggleRequested(
    LikeToggleRequested event,
    Emitter<LikeState> emit,
  ) async {
    final optimisticIsLiked = !event.isCurrentlyLiked;
    final optimisticCount = event.isCurrentlyLiked
        ? event.currentCount - 1
        : event.currentCount + 1;

    emit(LikeLoaded(isLiked: optimisticIsLiked, likeCount: optimisticCount));

    try {
      if (event.isCurrentlyLiked) {
        await _repository.unlikePost(
          postId: event.postId,
          currentUserId: event.currentUserId,
        );
      } else {
        await _repository.likePost(
          postId: event.postId,
          currentUserId: event.currentUserId,
        );
      }
    } catch (e) {
      // Revert to previous state on error.
      emit(LikeLoaded(
        isLiked: event.isCurrentlyLiked,
        likeCount: event.currentCount,
      ));
    }
  }
}
