// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/presentation/bloc/create_post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/create_post_event.dart';
import 'package:echo/features/posts/presentation/bloc/create_post_state.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  group('CreatePostBloc', () {
    late MockPostRepository mockPostRepository;
    late CreatePostBloc createPostBloc;

    setUp(() {
      mockPostRepository = MockPostRepository();
      createPostBloc = CreatePostBloc(repository: mockPostRepository);
    });

    tearDown(() {
      createPostBloc.close();
    });

    group('initial state', () {
      test('emits CreatePostInitial state on initialization', () {
        expect(createPostBloc.state, isA<CreatePostInitial>());
      });
    });

    group('CreatePostImagePicked', () {
      blocTest<CreatePostBloc, CreatePostState>(
        'transitions to CreatePostDraft with imagePath on CreatePostImagePicked',
        build: () => createPostBloc,
        act: (bloc) => bloc.add(
          const CreatePostImagePicked(imagePath: '/path/to/image.jpg'),
        ),
        expect: () => [
          isA<CreatePostDraft>()
              .having((state) => state.imagePath, 'imagePath', '/path/to/image.jpg'),
        ],
      );
    });

    group('CreatePostImageCleared', () {
      blocTest<CreatePostBloc, CreatePostState>(
        'transitions to CreatePostDraft without image on CreatePostImageCleared',
        build: () => createPostBloc,
        act: (bloc) => bloc.add(const CreatePostImageCleared()),
        expect: () => [
          isA<CreatePostDraft>()
              .having((state) => state.imagePath, 'imagePath', isNull),
        ],
      );
    });

    group('CreatePostSubmitted', () {
      blocTest<CreatePostBloc, CreatePostState>(
        'emits [CreatePostSubmitting, CreatePostSuccess] on successful submit',
        setUp: () {
          when(() => mockPostRepository.createPost(
            authorId: any(named: 'authorId'),
            content: any(named: 'content'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async {});
        },
        build: () => createPostBloc,
        act: (bloc) => bloc.add(
          const CreatePostSubmitted(
            authorId: 'user-1',
            content: 'Hello world',
          ),
        ),
        expect: () => [
          isA<CreatePostSubmitting>(),
          isA<CreatePostSuccess>(),
        ],
      );

      blocTest<CreatePostBloc, CreatePostState>(
        'emits [CreatePostSubmitting, CreatePostFailure] on submit failure',
        setUp: () {
          when(() => mockPostRepository.createPost(
            authorId: any(named: 'authorId'),
            content: any(named: 'content'),
            imagePath: any(named: 'imagePath'),
          )).thenThrow(Exception('Create failed'));
        },
        build: () => createPostBloc,
        act: (bloc) => bloc.add(
          const CreatePostSubmitted(
            authorId: 'user-1',
            content: 'Hello world',
          ),
        ),
        expect: () => [
          isA<CreatePostSubmitting>(),
          isA<CreatePostFailure>(),
        ],
      );
    });
  });
}
