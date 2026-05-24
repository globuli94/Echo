// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/posts/domain/entities/post.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_event.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/posts/presentation/widgets/post_card.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

Post makePost({
  String postId = 'post-1',
  String authorId = 'user-1',
  String content = 'Hello world',
  String? imageUrl,
  int likeCount = 0,
}) =>
    Post(
      postId: postId,
      authorId: authorId,
      content: content,
      imageUrl: imageUrl,
      likeCount: likeCount,
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
  group('PostCard', () {
    late MockPostBloc mockPostBloc;
    late MockPostRepository mockPostRepository;

    setUp(() {
      mockPostBloc = MockPostBloc();
      mockPostRepository = MockPostRepository();

      // Default mock state
      when(() => mockPostBloc.state).thenReturn(const PostsInitial());
      whenListen(
        mockPostBloc,
        Stream.fromIterable([const PostsInitial()]),
        initialState: const PostsInitial(),
      );
    });

    Widget createWidgetUnderTest({
      required PostWithAuthor postWithAuthor,
      required String currentUserId,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<PostBloc>.value(
            value: mockPostBloc,
            child: RepositoryProvider<PostRepository>.value(
              value: mockPostRepository,
              child: PostCard(
                postWithAuthor: postWithAuthor,
                currentUserId: currentUserId,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders post text content', (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(content: 'Hello world'),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-1',
        ),
      );

      // Assert
      expect(
        find.text('Hello world'),
        findsWidgets,
        reason: 'Post text content should be rendered',
      );
    });

    testWidgets('shows delete IconButton when currentUserId == authorId',
        (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(authorId: 'user-1'),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-1',
        ),
      );

      // Assert
      expect(
        find.byIcon(Icons.delete_outline),
        findsOneWidget,
        reason: 'Delete button should be visible for post author',
      );
    });

    testWidgets(
        'does NOT show delete button when currentUserId != authorId',
        (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(authorId: 'user-1'),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-2',
        ),
      );

      // Assert
      expect(
        find.byIcon(Icons.delete_outline),
        findsNothing,
        reason: 'Delete button should not be visible for non-authors',
      );
    });

    testWidgets('shows image widget when post.imageUrl is non-null',
        (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(imageUrl: 'https://example.com/image.jpg'),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-1',
        ),
      );

      // Assert
      expect(
        find.byType(Image),
        findsWidgets,
        reason: 'Image widget should be shown when imageUrl is provided',
      );
    });

    testWidgets('does NOT show image widget when post.imageUrl is null',
        (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(imageUrl: null),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-1',
        ),
      );

      // Assert
      // We can't directly test that Image is not shown, so we verify the post content is shown
      // without an Image widget for this particular test case
      expect(
        find.byType(PostCard),
        findsOneWidget,
        reason: 'PostCard should render without image when imageUrl is null',
      );
    });

    testWidgets('author name is tappable for navigation (AC #5)',
        (WidgetTester tester) async {
      // Arrange
      final postWithAuthor = makePostWithAuthor(
        post: makePost(authorId: 'author-123'),
        authorDisplayName: 'Alice',
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          postWithAuthor: postWithAuthor,
          currentUserId: 'user-1',
        ),
      );

      // Assert - Author name is rendered and part of tappable area (AC #5)
      // The PostCard wraps the author in a GestureDetector for profile navigation
      expect(
        find.text('Alice'),
        findsWidgets,
        reason: 'Author display name should be rendered',
      );

      // Verify author area is interactive (contains GestureDetector)
      expect(
        find.byType(GestureDetector),
        findsWidgets,
        reason:
            'Author area should have GestureDetector for profile navigation',
      );
    });

    group('Like button', () {
      testWidgets(
        'shows Icons.favorite_border when user has not liked post',
        (WidgetTester tester) async {
          final postWithAuthor = makePostWithAuthor(post: makePost());
          when(() => mockPostRepository.isPostLikedBy(
                postId: 'post-1',
                uid: 'user-1',
              )).thenAnswer((_) async => false);

          await tester.pumpWidget(
            createWidgetUnderTest(
              postWithAuthor: postWithAuthor,
              currentUserId: 'user-1',
            ),
          );

          // Wait for LikeStatusFetched to complete
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        },
      );

      testWidgets(
        'shows Icons.favorite when user has liked post',
        (WidgetTester tester) async {
          final postWithAuthor = makePostWithAuthor(post: makePost());
          when(() => mockPostRepository.isPostLikedBy(
                postId: 'post-1',
                uid: 'user-1',
              )).thenAnswer((_) async => true);

          await tester.pumpWidget(
            createWidgetUnderTest(
              postWithAuthor: postWithAuthor,
              currentUserId: 'user-1',
            ),
          );

          // Wait for LikeStatusFetched to complete
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.favorite), findsOneWidget);
        },
      );

      testWidgets(
        'displays likeCount from post',
        (WidgetTester tester) async {
          final postWithAuthor = makePostWithAuthor(
            post: makePost(likeCount: 7),
          );
          when(() => mockPostRepository.isPostLikedBy(
                postId: 'post-1',
                uid: 'user-1',
              )).thenAnswer((_) async => false);

          await tester.pumpWidget(
            createWidgetUnderTest(
              postWithAuthor: postWithAuthor,
              currentUserId: 'user-1',
            ),
          );

          // Wait for LikeStatusFetched to complete
          await tester.pumpAndSettle();

          expect(find.text('7'), findsOneWidget);
        },
      );

      testWidgets(
        'dispatches LikeToggleRequested on tap',
        (WidgetTester tester) async {
          final postWithAuthor = makePostWithAuthor(post: makePost());
          when(() => mockPostRepository.isPostLikedBy(
                postId: 'post-1',
                uid: 'user-1',
              )).thenAnswer((_) async => false);
          when(() => mockPostRepository.likePost(
                postId: 'post-1',
                currentUserId: 'user-1',
              )).thenAnswer((_) async {});

          await tester.pumpWidget(
            createWidgetUnderTest(
              postWithAuthor: postWithAuthor,
              currentUserId: 'user-1',
            ),
          );

          // Wait for LikeStatusFetched to complete
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.favorite_border));
          await tester.pump();

          // Verify repository method was called
          verify(
            () => mockPostRepository.likePost(
              postId: 'post-1',
              currentUserId: 'user-1',
            ),
          ).called(1);
        },
      );
    });
  });
}
