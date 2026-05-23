// lib/features/posts/presentation/bloc/create_post_event.dart
//
// CreatePostEvent — sealed hierarchy of events for [CreatePostBloc].

import 'package:equatable/equatable.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

/// User picked an image from gallery.
final class CreatePostImagePicked extends CreatePostEvent {
  const CreatePostImagePicked({required this.imagePath});

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// User removed the selected image.
final class CreatePostImageCleared extends CreatePostEvent {
  const CreatePostImageCleared();
}

/// User submitted the post.
final class CreatePostSubmitted extends CreatePostEvent {
  const CreatePostSubmitted({required this.authorId, required this.content});

  final String authorId;
  final String content;

  @override
  List<Object?> get props => [authorId, content];
}
