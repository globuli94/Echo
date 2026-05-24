// lib/features/posts/presentation/bloc/like_event.dart

import 'package:equatable/equatable.dart';

sealed class LikeEvent extends Equatable {
  const LikeEvent();

  @override
  List<Object?> get props => [];
}

final class LikeStatusFetched extends LikeEvent {
  const LikeStatusFetched({
    required this.postId,
    required this.currentUserId,
    required this.initialCount,
  });

  final String postId;
  final String currentUserId;
  final int initialCount;

  @override
  List<Object?> get props => [postId, currentUserId, initialCount];
}

final class LikeToggleRequested extends LikeEvent {
  const LikeToggleRequested({
    required this.postId,
    required this.currentUserId,
    required this.isCurrentlyLiked,
    required this.currentCount,
  });

  final String postId;
  final String currentUserId;
  final bool isCurrentlyLiked;
  final int currentCount;

  @override
  List<Object?> get props =>
      [postId, currentUserId, isCurrentlyLiked, currentCount];
}
