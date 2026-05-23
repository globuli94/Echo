// lib/features/posts/presentation/bloc/create_post_state.dart
//
// CreatePostState — sealed hierarchy of states for [CreatePostBloc].

import 'package:equatable/equatable.dart';

sealed class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any interaction.
final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial();
}

/// User is composing a post draft.
final class CreatePostDraft extends CreatePostState {
  const CreatePostDraft({this.imagePath});

  final String? imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Post is being submitted.
final class CreatePostSubmitting extends CreatePostState {
  const CreatePostSubmitting();
}

/// Post was created successfully.
final class CreatePostSuccess extends CreatePostState {
  const CreatePostSuccess();
}

/// Post creation failed.
final class CreatePostFailure extends CreatePostState {
  const CreatePostFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
