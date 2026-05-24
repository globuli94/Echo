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
///
/// [currentUid] is used to build the followed-user feed: the feed shows posts
/// from followed users plus the authenticated user's own posts.
final class PostsFeedSubscribed extends PostEvent {
  const PostsFeedSubscribed({this.currentUid = ''});

  final String currentUid;

  @override
  List<Object?> get props => [currentUid];
}

/// Requests a full feed refresh, replacing all currently loaded posts with
/// a fresh first page.
final class PostsFeedRefreshed extends PostEvent {
  const PostsFeedRefreshed({this.currentUid = ''});

  final String currentUid;

  @override
  List<Object?> get props => [currentUid];
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

/// Toggles the like state on a post.
///
/// When [isCurrentlyLiked] is true, the post will be unliked; otherwise liked.
/// A like notification is sent to [postAuthorId] when liking (not unliking).
final class PostLikeToggled extends PostEvent {
  const PostLikeToggled({
    required this.postId,
    required this.postAuthorId,
    required this.isCurrentlyLiked,
    required this.actorUid,
    required this.actorDisplayName,
    this.actorAvatarUrl,
  });

  final String postId;
  final String postAuthorId;
  final bool isCurrentlyLiked;
  final String actorUid;
  final String actorDisplayName;
  final String? actorAvatarUrl;

  @override
  List<Object?> get props => [
        postId,
        postAuthorId,
        isCurrentlyLiked,
        actorUid,
        actorDisplayName,
        actorAvatarUrl,
      ];
}
