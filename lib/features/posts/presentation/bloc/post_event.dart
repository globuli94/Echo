// lib/features/posts/presentation/bloc/post_event.dart
//
// PostEvent — sealed hierarchy of events for [PostBloc].

import 'package:equatable/equatable.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers an initial fetch of the post feed (first page).
final class PostsFeedSubscribed extends PostEvent {
  const PostsFeedSubscribed();
}

/// Requests a full feed refresh, replacing all currently loaded posts with
/// a fresh first page.
final class PostsFeedRefreshed extends PostEvent {
  const PostsFeedRefreshed();
}

/// Requests loading the next page of posts when the user scrolls near the
/// bottom of the feed.
final class PostsFeedLoadMore extends PostEvent {
  const PostsFeedLoadMore();
}

/// Requests deletion of a post by [postId].
final class PostDeleteRequested extends PostEvent {
  const PostDeleteRequested({required this.postId, required this.authorId});

  final String postId;
  final String authorId;

  @override
  List<Object?> get props => [postId, authorId];
}
