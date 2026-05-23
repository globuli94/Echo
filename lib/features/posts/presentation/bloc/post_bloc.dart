// lib/features/posts/presentation/bloc/post_bloc.dart
//
// PostBloc — manages paginated feed loading, pull-to-refresh, and post
// deletion.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  /// Number of posts fetched per page.
  static const int _pageSize = 15;

  PostBloc({required PostRepository repository})
      : _repository = repository,
        super(const PostsInitial()) {
    on<PostsFeedSubscribed>(_onFeedSubscribed);
    on<PostsFeedRefreshed>(_onFeedRefreshed);
    on<PostsFeedLoadMore>(_onLoadMore);
    on<PostDeleteRequested>(_onDeleteRequested);
  }

  final PostRepository _repository;

  Future<void> _onFeedSubscribed(
    PostsFeedSubscribed event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostsLoading());
    try {
      final page = await _repository.fetchFeedPage(limit: _pageSize);
      emit(PostsLoaded(
        posts: page.posts,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      ));
    } catch (e) {
      emit(PostsError(message: e.toString()));
    }
  }

  Future<void> _onFeedRefreshed(
    PostsFeedRefreshed event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostsLoading());
    try {
      final page = await _repository.fetchFeedPage(limit: _pageSize);
      emit(PostsLoaded(
        posts: page.posts,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      ));
    } catch (e) {
      emit(PostsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    PostsFeedLoadMore event,
    Emitter<PostState> emit,
  ) async {
    final current = state;
    if (current is! PostsLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.fetchFeedPage(
        before: current.nextCursor,
        limit: _pageSize,
      );
      emit(current.copyWith(
        posts: [...current.posts, ...page.posts],
        hasMore: page.hasMore,
        isLoadingMore: false,
        nextCursor: page.nextCursor,
      ));
    } catch (_) {
      // Restore previous state without the loading indicator; the feed
      // remains usable even if a pagination request fails.
      emit(current.copyWith(isLoadingMore: false));
    }
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
      // Optimistically remove the deleted post from the visible list.
      if (state is PostsLoaded) {
        final current = state as PostsLoaded;
        emit(current.copyWith(
          posts: current.posts
              .where((p) => p.post.postId != event.postId)
              .toList(),
        ));
      }
    } catch (e) {
      emit(PostsError(message: e.toString()));
    }
  }
}
