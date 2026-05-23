// lib/features/posts/presentation/bloc/user_posts_bloc.dart
//
// UserPostsBloc — manages loading the post list for a given user profile.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import 'user_posts_event.dart';
import 'user_posts_state.dart';

/// BLoC that loads posts authored by a specific user, used on ProfileScreen.
class UserPostsBloc extends Bloc<UserPostsEvent, UserPostsState> {
  UserPostsBloc({required PostRepository repository})
      : _repository = repository,
        super(const UserPostsInitial()) {
    on<UserPostsLoadRequested>(_onLoadRequested);
  }

  final PostRepository _repository;

  Future<void> _onLoadRequested(
    UserPostsLoadRequested event,
    Emitter<UserPostsState> emit,
  ) async {
    emit(const UserPostsLoading());
    try {
      final page = await _repository.fetchUserPosts(authorId: event.authorId);
      emit(UserPostsLoaded(posts: page.posts));
    } catch (e) {
      emit(UserPostsError(message: e.toString()));
    }
  }
}
