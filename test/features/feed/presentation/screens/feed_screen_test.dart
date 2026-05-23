// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo/features/auth/domain/repositories/auth_repository.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/domain/entities/post.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/feed/presentation/screens/feed_screen.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

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
    late MockPostRepository mockPostRepository;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockAuthRepository = MockAuthRepository();
    });

    Widget createWidgetUnderTest({
      PostBloc? postBloc,
    }) {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            if (postBloc != null)
              BlocProvider<PostBloc>(
                create: (context) => postBloc,
              )
            else
              BlocProvider<PostBloc>(
                create: (context) => PostBloc(repository: mockPostRepository),
              ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(repository: mockAuthRepository),
            ),
          ],
          child: const FeedScreen(),
        ),
      );
    }

    testWidgets('shows CircularProgressIndicator when PostBloc is in PostsLoading',
        (WidgetTester tester) async {
      // Arrange
      final postBloc = PostBloc(repository: mockPostRepository);
      // Manually emit PostsLoading state
      postBloc.emit(PostsLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest(postBloc: postBloc));

      // Assert
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
        reason:
            'CircularProgressIndicator should be shown when PostBloc is in PostsLoading',
      );

      addTearDown(postBloc.close);
    });

    testWidgets('shows "No posts yet" when PostBloc emits PostsLoaded with empty list',
        (WidgetTester tester) async {
      // Arrange
      final postBloc = PostBloc(repository: mockPostRepository);
      postBloc.emit(const PostsLoaded(posts: []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(postBloc: postBloc));

      // Assert
      expect(
        find.text('No posts yet'),
        findsWidgets,
        reason: 'Should show "No posts yet" when the feed is empty',
      );

      addTearDown(postBloc.close);
    });

    testWidgets(
        'shows list of post content when PostBloc emits PostsLoaded with posts',
        (WidgetTester tester) async {
      // Arrange
      final postBloc = PostBloc(repository: mockPostRepository);
      final posts = [
        makePostWithAuthor(post: makePost(content: 'First post')),
        makePostWithAuthor(post: makePost(postId: 'post-2', content: 'Second post')),
      ];
      postBloc.emit(PostsLoaded(posts: posts));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(postBloc: postBloc));

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

      addTearDown(postBloc.close);
    });

    testWidgets('shows FloatingActionButton when PostBloc is in the tree',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
        reason: 'FloatingActionButton should be shown when PostBloc is in the tree',
      );
    });
  });
}
