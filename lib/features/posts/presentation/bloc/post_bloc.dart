// lib/features/posts/presentation/bloc/post_bloc.dart
//
// PostBloc — manages feed subscription and post deletion.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required PostRepository repository})
      : _repository = repository,
        super(const PostsInitial()) {
    on<PostsFeedSubscribed>(_onFeedSubscribed);
    on<PostDeleteRequested>(_onDeleteRequested);
  }

  final PostRepository _repository;

  Future<void> _onFeedSubscribed(
    PostsFeedSubscribed event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostsLoading());
    await emit.forEach(
      _repository.streamFeed(),
      onData: (posts) => PostsLoaded(posts: posts),
      onError: (error, _) => PostsError(message: error.toString()),
    );
  }

  Future<void> _onDeleteRequested(
    PostDeleteRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      await _repository.deletePost(
        postId: event.postId,
        authorId: event.authorId,
      );
    } catch (e) {
      emit(PostsError(message: e.toString()));
    }
  }
}
