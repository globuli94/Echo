import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/presentation/bloc/like_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/like_event.dart';
import 'package:echo/features/posts/presentation/bloc/like_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockPostRepository;

  group('LikeBloc', () {
    group('LikeStatusFetched', () {
      blocTest<LikeBloc, LikeState>(
        'emits [LikeLoading, LikeLoaded(isLiked: false, likeCount: 3)] '
        'when LikeStatusFetched succeeds and user has not liked',
        build: () {
          mockPostRepository = MockPostRepository();
          const postId = 'post-1';
          const userId = 'user-1';
          const initialCount = 3;

          when(() => mockPostRepository.isPostLikedBy(
                postId: postId,
                uid: userId,
              )).thenAnswer((_) async => false);

          return LikeBloc(repository: mockPostRepository);
        },
        act: (bloc) {
          bloc.add(const LikeStatusFetched(
            postId: 'post-1',
            currentUserId: 'user-1',
            initialCount: 3,
          ));
        },
        expect: () => [
          isA<LikeLoading>(),
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', false)
              .having((state) => state.likeCount, 'likeCount', 3),
        ],
      );

      blocTest<LikeBloc, LikeState>(
        'emits [LikeLoading, LikeLoaded(isLiked: true, likeCount: 5)] '
        'when LikeStatusFetched succeeds and user has liked',
        build: () {
          mockPostRepository = MockPostRepository();
          const postId = 'post-2';
          const userId = 'user-2';
          const initialCount = 5;

          when(() => mockPostRepository.isPostLikedBy(
                postId: postId,
                uid: userId,
              )).thenAnswer((_) async => true);

          return LikeBloc(repository: mockPostRepository);
        },
        act: (bloc) {
          bloc.add(const LikeStatusFetched(
            postId: 'post-2',
            currentUserId: 'user-2',
            initialCount: 5,
          ));
        },
        expect: () => [
          isA<LikeLoading>(),
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', true)
              .having((state) => state.likeCount, 'likeCount', 5),
        ],
      );
    });

    group('LikeToggleRequested', () {
      blocTest<LikeBloc, LikeState>(
        'optimistically toggles to liked and emits '
        'LikeLoaded(isLiked: true, likeCount: 4) '
        'when LikeToggleRequested(isCurrentlyLiked: false, currentCount: 3) succeeds',
        build: () {
          mockPostRepository = MockPostRepository();
          const postId = 'post-3';
          const userId = 'user-3';

          when(() => mockPostRepository.likePost(
                postId: postId,
                currentUserId: userId,
              )).thenAnswer((_) async {});

          return LikeBloc(repository: mockPostRepository);
        },
        act: (bloc) {
          bloc.add(const LikeToggleRequested(
            postId: 'post-3',
            currentUserId: 'user-3',
            isCurrentlyLiked: false,
            currentCount: 3,
          ));
        },
        expect: () => [
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', true)
              .having((state) => state.likeCount, 'likeCount', 4),
        ],
      );

      blocTest<LikeBloc, LikeState>(
        'optimistically toggles to unliked and emits '
        'LikeLoaded(isLiked: false, likeCount: 2) '
        'when LikeToggleRequested(isCurrentlyLiked: true, currentCount: 3) succeeds',
        build: () {
          mockPostRepository = MockPostRepository();
          const postId = 'post-4';
          const userId = 'user-4';

          when(() => mockPostRepository.unlikePost(
                postId: postId,
                currentUserId: userId,
              )).thenAnswer((_) async {});

          return LikeBloc(repository: mockPostRepository);
        },
        act: (bloc) {
          bloc.add(const LikeToggleRequested(
            postId: 'post-4',
            currentUserId: 'user-4',
            isCurrentlyLiked: true,
            currentCount: 3,
          ));
        },
        expect: () => [
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', false)
              .having((state) => state.likeCount, 'likeCount', 2),
        ],
      );

      blocTest<LikeBloc, LikeState>(
        'reverts state when likePost throws',
        build: () {
          mockPostRepository = MockPostRepository();
          const postId = 'post-5';
          const userId = 'user-5';

          when(() => mockPostRepository.likePost(
                postId: postId,
                currentUserId: userId,
              )).thenThrow(Exception('Network error'));

          return LikeBloc(repository: mockPostRepository);
        },
        act: (bloc) {
          bloc.add(const LikeToggleRequested(
            postId: 'post-5',
            currentUserId: 'user-5',
            isCurrentlyLiked: false,
            currentCount: 2,
          ));
        },
        expect: () => [
          // Optimistic state: trying to like
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', true)
              .having((state) => state.likeCount, 'likeCount', 3),
          // Reverted state: error occurred, revert to original
          isA<LikeLoaded>()
              .having((state) => state.isLiked, 'isLiked', false)
              .having((state) => state.likeCount, 'likeCount', 2),
        ],
      );
    });
  });
}

