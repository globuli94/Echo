// SPDX-License-Identifier: MIT
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/domain/entities/post.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_event.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';

class MockPostRepository extends Mock implements PostRepository {}

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
  group('PostBloc', () {
    late MockPostRepository mockPostRepository;
    late PostBloc postBloc;

    setUp(() {
      mockPostRepository = MockPostRepository();
      postBloc = PostBloc(repository: mockPostRepository);
    });

    tearDown(() {
      postBloc.close();
    });

    group('initial state', () {
      test('emits PostsInitial state on initialization', () {
        expect(postBloc.state, isA<PostsInitial>());
      });
    });

    group('PostsFeedSubscribed', () {
      late StreamController<List<PostWithAuthor>> controller;

      setUp(() {
        controller = StreamController<List<PostWithAuthor>>();
      });

      tearDown(() {
        controller.close();
      });

      blocTest<PostBloc, PostState>(
        'emits [PostsLoading, PostsLoaded] when stream emits',
        setUp: () {
          when(() => mockPostRepository.streamFeed())
              .thenAnswer((_) => controller.stream);
        },
        build: () => postBloc,
        act: (bloc) {
          bloc.add(const PostsFeedSubscribed());
          controller.add([makePostWithAuthor()]);
        },
        expect: () => [
          isA<PostsLoading>(),
          isA<PostsLoaded>(),
        ],
      );

      blocTest<PostBloc, PostState>(
        'emits PostsError when stream errors',
        setUp: () {
          when(() => mockPostRepository.streamFeed())
              .thenAnswer((_) => controller.stream);
        },
        build: () => postBloc,
        act: (bloc) {
          bloc.add(const PostsFeedSubscribed());
          controller.addError(Exception('Stream error'));
        },
        expect: () => [
          isA<PostsLoading>(),
          isA<PostsError>(),
        ],
      );
    });

    group('PostDeleteRequested', () {
      blocTest<PostBloc, PostState>(
        'calls repository.deletePost() when PostDeleteRequested is added',
        setUp: () {
          when(() => mockPostRepository.deletePost(
            postId: 'post-1',
            authorId: 'user-1',
          )).thenAnswer((_) async {});
        },
        build: () => postBloc,
        act: (bloc) => bloc.add(
          const PostDeleteRequested(
            postId: 'post-1',
            authorId: 'user-1',
          ),
        ),
        verify: (bloc) {
          verify(() => mockPostRepository.deletePost(
            postId: 'post-1',
            authorId: 'user-1',
          )).called(1);
        },
      );
    });
  });
}
