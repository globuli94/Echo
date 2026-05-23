// lib/features/posts/presentation/bloc/post_state.dart
//
// PostState — sealed hierarchy of states emitted by [PostBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/post_with_author.dart';

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any feed subscription.
final class PostsInitial extends PostState {
  const PostsInitial();
}

/// Feed is loading.
final class PostsLoading extends PostState {
  const PostsLoading();
}

/// Feed is loaded with the given list of posts.
final class PostsLoaded extends PostState {
  const PostsLoaded({required this.posts});

  final List<PostWithAuthor> posts;

  @override
  List<Object?> get props => [posts];
}

/// An error occurred while loading or deleting.
final class PostsError extends PostState {
  const PostsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
