// lib/features/posts/presentation/bloc/post_state.dart
//
// PostState — sealed hierarchy of states emitted by [PostBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/post_with_author.dart';

// Sentinel used by [PostsLoaded.copyWith] to distinguish "not provided"
// from an explicit null for the nullable [PostsLoaded.nextCursor] field.
const Object _absent = Object();

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any feed fetch.
final class PostsInitial extends PostState {
  const PostsInitial();
}

/// Feed is loading (initial load or pull-to-refresh).
final class PostsLoading extends PostState {
  const PostsLoading();
}

/// Feed has loaded successfully.
final class PostsLoaded extends PostState {
  /// Creates a [PostsLoaded] state.
  const PostsLoaded({
    required this.posts,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.nextCursor,
  });

  /// The posts visible in the feed so far (accumulates across pages).
  final List<PostWithAuthor> posts;

  /// Whether the repository reported more posts after this batch.
  final bool hasMore;

  /// True while a "load more" page request is in flight.
  final bool isLoadingMore;

  /// Cursor passed to [PostRepository.fetchFeedPage] to load the next page.
  final DateTime? nextCursor;

  /// Returns a copy of this state with the given fields overridden.
  ///
  /// Pass `nextCursor: null` explicitly to clear the cursor. Omitting
  /// [nextCursor] keeps the existing value.
  PostsLoaded copyWith({
    List<PostWithAuthor>? posts,
    bool? hasMore,
    bool? isLoadingMore,
    Object? nextCursor = _absent,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextCursor: identical(nextCursor, _absent)
          ? this.nextCursor
          : nextCursor as DateTime?,
    );
  }

  @override
  List<Object?> get props => [posts, hasMore, isLoadingMore, nextCursor];
}

/// An error occurred while loading or deleting.
final class PostsError extends PostState {
  const PostsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
