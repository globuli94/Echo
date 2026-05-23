// lib/features/posts/presentation/bloc/post_event.dart
//
// PostEvent — sealed hierarchy of events for [PostBloc].

import 'package:equatable/equatable.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers subscription to the live post feed stream.
final class PostsFeedSubscribed extends PostEvent {
  const PostsFeedSubscribed();
}

/// Requests deletion of a post by [postId].
final class PostDeleteRequested extends PostEvent {
  const PostDeleteRequested({required this.postId, required this.authorId});

  final String postId;
  final String authorId;

  @override
  List<Object?> get props => [postId, authorId];
}
