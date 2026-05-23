// lib/features/posts/presentation/bloc/user_posts_event.dart
//
// UserPostsEvent — events for [UserPostsBloc].

import 'package:equatable/equatable.dart';

sealed class UserPostsEvent extends Equatable {
  const UserPostsEvent();

  @override
  List<Object?> get props => [];
}

/// Requests loading posts authored by [authorId].
final class UserPostsLoadRequested extends UserPostsEvent {
  const UserPostsLoadRequested({required this.authorId});

  final String authorId;

  @override
  List<Object?> get props => [authorId];
}
