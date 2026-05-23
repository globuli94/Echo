// lib/features/posts/presentation/bloc/user_posts_state.dart
//
// UserPostsState — states emitted by [UserPostsBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/post_with_author.dart';

sealed class UserPostsState extends Equatable {
  const UserPostsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load request.
final class UserPostsInitial extends UserPostsState {
  const UserPostsInitial();
}

/// Posts are being fetched.
final class UserPostsLoading extends UserPostsState {
  const UserPostsLoading();
}

/// Posts loaded successfully.
final class UserPostsLoaded extends UserPostsState {
  const UserPostsLoaded({required this.posts});

  final List<PostWithAuthor> posts;

  @override
  List<Object?> get props => [posts];
}

/// An error occurred while loading posts.
final class UserPostsError extends UserPostsState {
  const UserPostsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
