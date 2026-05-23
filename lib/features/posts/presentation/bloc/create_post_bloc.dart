// lib/features/posts/presentation/bloc/create_post_bloc.dart
//
// CreatePostBloc — manages image selection and post creation flow.
// Scoped to the CreatePostScreen route — NOT registered in main.dart.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import 'create_post_event.dart';
import 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  CreatePostBloc({required PostRepository repository})
      : _repository = repository,
        super(const CreatePostInitial()) {
    on<CreatePostImagePicked>(_onImagePicked);
    on<CreatePostImageCleared>(_onImageCleared);
    on<CreatePostSubmitted>(_onSubmitted);
  }

  final PostRepository _repository;

  void _onImagePicked(
    CreatePostImagePicked event,
    Emitter<CreatePostState> emit,
  ) {
    emit(CreatePostDraft(imagePath: event.imagePath));
  }

  void _onImageCleared(
    CreatePostImageCleared event,
    Emitter<CreatePostState> emit,
  ) {
    emit(const CreatePostDraft());
  }

  Future<void> _onSubmitted(
    CreatePostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    final currentState = state;
    final imagePath =
        currentState is CreatePostDraft ? currentState.imagePath : null;

    emit(const CreatePostSubmitting());
    try {
      await _repository.createPost(
        authorId: event.authorId,
        content: event.content,
        imagePath: imagePath,
      );
      emit(const CreatePostSuccess());
    } catch (e) {
      emit(CreatePostFailure(message: e.toString()));
    }
  }
}
