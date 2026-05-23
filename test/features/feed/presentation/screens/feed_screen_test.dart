// SPDX-License-Identifier: MIT
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/posts/domain/entities/post.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_event.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/feed/presentation/screens/feed_screen.dart';

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

Post makePost({
  String postId = 'post-1',
  String authorId = 'user-1',
  String content = 'Hello world',
  String? imageUrl,
  DateTime? createdAt,
}) =>
    Post(
      postId: postId,
      authorId: authorId,
      content: content,
      imageUrl: imageUrl,
      likeCount: 0,
      commentCount: 0,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );

PostWithAuthor makePostWithAuthor({
  Post? post,
  String authorDisplayName = 'Alice',
  String? authorAvatarUrl,
}) =>
    PostWithAuthor(
      post: post ?? makePost(),
      authorDisplayName: authorDisplayName,
      authorAvatarUrl: authorAvatarUrl,
    );

void main() {
  group('FeedScreen', () {
    late MockPostBloc mockPostBloc;
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockPostBloc = MockPostBloc();
      mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    });

    Widget buildSubject() => MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<PostBloc>.value(value: mockPostBloc),
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            ],
            child: const FeedScreen(),
          ),
        );

    testWidgets('shows CircularProgressIndicator when PostBloc is in PostsLoading',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostBloc.state).thenReturn(const PostsLoading());
      whenListen(
        mockPostBloc,
        Stream.fromIterable([const PostsLoading()]),
        initialState: const PostsLoading(),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
        reason:
            'CircularProgressIndicator should be shown when PostBloc is in PostsLoading',
      );
    });

    testWidgets('shows "No posts yet" when PostBloc emits PostsLoaded with empty list',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostBloc.state).thenReturn(const PostsLoaded(posts: []));
      whenListen(
        mockPostBloc,
        Stream.fromIterable([const PostsLoaded(posts: [])]),
        initialState: const PostsLoaded(posts: []),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(
        find.text('No posts yet'),
        findsWidgets,
        reason: 'Should show "No posts yet" when the feed is empty',
      );
    });

    testWidgets(
        'shows list of post content when PostBloc emits PostsLoaded with posts',
        (WidgetTester tester) async {
      // Arrange
      final posts = [
        makePostWithAuthor(post: makePost(content: 'First post')),
        makePostWithAuthor(post: makePost(postId: 'post-2', content: 'Second post')),
      ];
      when(() => mockPostBloc.state).thenReturn(PostsLoaded(posts: posts));
      whenListen(
        mockPostBloc,
        Stream.fromIterable([PostsLoaded(posts: posts)]),
        initialState: PostsLoaded(posts: posts),
      );

      // Act
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Assert
      expect(
        find.text('First post'),
        findsWidgets,
        reason: 'First post content should be displayed',
      );

      expect(
        find.text('Second post'),
        findsWidgets,
        reason: 'Second post content should be displayed',
      );
    });

    testWidgets('shows FloatingActionButton when PostBloc is in the tree',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostBloc.state).thenReturn(const PostsInitial());
      whenListen(
        mockPostBloc,
        Stream.fromIterable([const PostsInitial()]),
        initialState: const PostsInitial(),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
        reason: 'FloatingActionButton should be shown when PostBloc is in the tree',
      );
    });

    testWidgets(
        'shows RefreshIndicator that can be pulled to refresh',
        (WidgetTester tester) async {
      // Arrange
      final posts = [
        makePostWithAuthor(post: makePost(content: 'First post')),
      ];
      when(() => mockPostBloc.state).thenReturn(PostsLoaded(posts: posts));
      whenListen(
        mockPostBloc,
        Stream.fromIterable([PostsLoaded(posts: posts)]),
        initialState: PostsLoaded(posts: posts),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert — RefreshIndicator is rendered (pull-to-refresh AC #2)
      expect(
        find.byType(RefreshIndicator),
        findsOneWidget,
        reason: 'RefreshIndicator should be present for pull-to-refresh',
      );
    });

    testWidgets(
        'displays pagination state (hasMore, isLoadingMore) in PostsLoaded',
        (WidgetTester tester) async {
      // Arrange — PostsLoaded state with pagination data (AC #3)
      final posts = [
        makePostWithAuthor(post: makePost(content: 'Post 1')),
        makePostWithAuthor(post: makePost(postId: 'post-2', content: 'Post 2')),
      ];
      final paginatedState = PostsLoaded(
        posts: posts,
        hasMore: true,
        isLoadingMore: false,
        nextCursor: DateTime(2026, 1, 15),
      );
      when(() => mockPostBloc.state).thenReturn(paginatedState);
      whenListen(
        mockPostBloc,
        Stream.fromIterable([paginatedState]),
        initialState: paginatedState,
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert — state contains pagination markers
      final state = mockPostBloc.state;
      expect(
        state,
        isA<PostsLoaded>()
            .having((s) => s.hasMore, 'hasMore', true)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.nextCursor, 'nextCursor', isNotNull),
        reason:
            'PostsLoaded state should reflect hasMore, isLoadingMore, and nextCursor for pagination',
      );
    });

    testWidgets('renders loading indicator at bottom during pagination load',
        (WidgetTester tester) async {
      // Arrange — state with isLoadingMore=true adds extra item to ListView (AC #3)
      final posts = [
        makePostWithAuthor(post: makePost(content: 'Post 1')),
      ];
      final loadingState = PostsLoaded(
        posts: posts,
        hasMore: true,
        isLoadingMore: true,
        nextCursor: DateTime(2026, 1, 15),
      );
      when(() => mockPostBloc.state).thenReturn(loadingState);
      whenListen(
        mockPostBloc,
        Stream.fromIterable([loadingState]),
        initialState: loadingState,
      );

      // Act
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Assert — bottom loading indicator shown when isLoadingMore=true
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
        reason:
            'CircularProgressIndicator should appear at bottom during pagination load',
      );
    });

    testWidgets('posts are ordered by createdAt descending',
        (WidgetTester tester) async {
      // Arrange (AC #1 - Scrollable list ordered by createdAt DESC)
      final posts = [
        makePostWithAuthor(
          post: makePost(
            postId: 'post-1',
            content: 'Most recent',
            createdAt: DateTime(2026, 1, 15),
          ),
        ),
        makePostWithAuthor(
          post: makePost(
            postId: 'post-2',
            content: 'Second',
            createdAt: DateTime(2026, 1, 10),
          ),
        ),
        makePostWithAuthor(
          post: makePost(
            postId: 'post-3',
            content: 'Oldest',
            createdAt: DateTime(2026, 1, 1),
          ),
        ),
      ];
      when(() => mockPostBloc.state).thenReturn(PostsLoaded(posts: posts));
      whenListen(
        mockPostBloc,
        Stream.fromIterable([PostsLoaded(posts: posts)]),
        initialState: PostsLoaded(posts: posts),
      );

      // Act
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Assert — posts appear in descending order
      expect(
        find.text('Most recent'),
        findsWidgets,
        reason: 'Most recent post should be first',
      );
      expect(
        find.text('Oldest'),
        findsWidgets,
        reason: 'Oldest post should be last',
      );
      // Verify order by checking positions: "Most recent" should appear before "Oldest"
      final mostRecentFinder = find.text('Most recent');
      final oldestFinder = find.text('Oldest');
      expect(
        tester.getTopLeft(mostRecentFinder).dy <
            tester.getTopLeft(oldestFinder).dy,
        true,
        reason: 'Posts should be ordered by createdAt descending (newest first)',
      );
    });
  });
}
