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
}) =>
    Post(
      postId: postId,
      authorId: authorId,
      content: content,
      imageUrl: imageUrl,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime(2026, 1, 1),
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
  });
}
