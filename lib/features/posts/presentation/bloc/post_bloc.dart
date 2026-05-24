// lib/features/posts/presentation/bloc/post_bloc.dart
//
// PostBloc — manages paginated feed loading, pull-to-refresh, and post
// deletion.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../follow/domain/repositories/follow_repository.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  /// Number of posts fetched per page.
  static const int _pageSize = 15;

  PostBloc({
    required PostRepository repository,
    FollowRepository? followRepository,
    NotificationRepository? notificationRepository,
  })  : _repository = repository,
        _followRepository = followRepository,
        _notificationRepository = notificationRepository,
        super(const PostsInitial()) {
    on<PostsFeedSubscribed>(_onFeedSubscribed);
    on<PostsFeedRefreshed>(_onFeedRefreshed);
    on<PostsFeedLoadMore>(_onLoadMore);
    on<PostDeleteRequested>(_onDeleteRequested);
    on<PostLikeToggled>(_onLikeToggled);
  }

  final PostRepository _repository;
  final FollowRepository? _followRepository;
  final NotificationRepository? _notificationRepository;

  /// Cached uid of the authenticated user, set on first feed load.
  String? _currentUid;

  Future<FeedPage> _fetchFollowedPage({
    required String currentUid,
    DateTime? before,
  }) async {
    final followRepo = _followRepository;
    if (followRepo == null || currentUid.isEmpty) {
      // Fall back to full feed when follow repository is unavailable.
      return _repository.fetchFeedPage(before: before, limit: _pageSize);
    }
    final followingUids =
        await followRepo.getFollowingUids(uid: currentUid);
    final authorIds = {...followingUids, currentUid}.toList();
    final ids =
        authorIds.length > 30 ? authorIds.take(30).toList() : authorIds;
    return _repository.fetchFollowedFeedPage(
      authorIds: ids,
      before: before,
      limit: _pageSize,
    );
  }

  Future<void> _onFeedSubscribed(
    PostsFeedSubscribed event,
    Emitter<PostState> emit,
  ) async {
    _currentUid = event.currentUid;
    emit(const PostsLoading());
    try {
      final page = await _fetchFollowedPage(currentUid: event.currentUid);
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
    _currentUid = event.currentUid;
    emit(const PostsLoading());
    try {
      final page = await _fetchFollowedPage(currentUid: event.currentUid);
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
      final uid = _currentUid;
      final FeedPage page;
      if (uid != null) {
        page = await _fetchFollowedPage(
          currentUid: uid,
          before: current.nextCursor,
        );
      } else {
        page = await _repository.fetchFeedPage(
          before: current.nextCursor,
          limit: _pageSize,
        );
      }
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

  Future<void> _onLikeToggled(
    PostLikeToggled event,
    Emitter<PostState> emit,
  ) async {
    try {
      if (event.isCurrentlyLiked) {
        await _repository.unlikePost(
          currentUserId: event.actorUid,
          postId: event.postId,
        );
      } else {
        await _repository.likePost(
          currentUserId: event.actorUid,
          postId: event.postId,
        );
        await _notificationRepository?.createLikeNotification(
          recipientUid: event.postAuthorId,
          actorUid: event.actorUid,
          actorDisplayName: event.actorDisplayName,
          actorAvatarUrl: event.actorAvatarUrl,
          postId: event.postId,
        );
      }
    } catch (_) {
      // Like/unlike errors are non-critical; likeCount is streamed on refresh.
    }
  }
}
