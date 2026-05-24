// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:echo/features/posts/data/repositories/post_repository_impl.dart';

class MockPostRemoteDataSource extends Mock
    implements PostRemoteDataSource {}

void main() {
  group('PostRepositoryImpl - Like Methods', () {
    late MockPostRemoteDataSource mockDataSource;
    late PostRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockPostRemoteDataSource();
      repository = PostRepositoryImpl(dataSource: mockDataSource);
    });

    group('likePost', () {
      test(
        'calls data source likePost with correct postId and uid',
        () async {
          // Arrange
          const postId = 'post-1';
          const uid = 'user-1';

          when(
            () => mockDataSource.likePost(postId: postId, uid: uid),
          ).thenAnswer((_) async {});

          // Act
          await repository.likePost(postId: postId, currentUserId: uid);

          // Assert
          verify(
            () => mockDataSource.likePost(postId: postId, uid: uid),
          ).called(1);
        },
      );
    });

    group('unlikePost', () {
      test(
        'calls data source unlikePost with correct postId and uid',
        () async {
          // Arrange
          const postId = 'post-2';
          const uid = 'user-2';

          when(
            () => mockDataSource.unlikePost(postId: postId, uid: uid),
          ).thenAnswer((_) async {});

          // Act
          await repository.unlikePost(postId: postId, currentUserId: uid);

          // Assert
          verify(
            () => mockDataSource.unlikePost(postId: postId, uid: uid),
          ).called(1);
        },
      );
    });

    group('isPostLikedBy', () {
      test(
        'returns true when data source returns true',
        () async {
          // Arrange
          const postId = 'post-3';
          const uid = 'user-3';

          when(
            () => mockDataSource.isPostLikedBy(postId: postId, uid: uid),
          ).thenAnswer((_) async => true);

          // Act
          final result = await repository.isPostLikedBy(postId: postId, uid: uid);

          // Assert
          expect(result, true);
        },
      );

      test(
        'returns false when data source returns false',
        () async {
          // Arrange
          const postId = 'post-4';
          const uid = 'user-4';

          when(
            () => mockDataSource.isPostLikedBy(postId: postId, uid: uid),
          ).thenAnswer((_) async => false);

          // Act
          final result = await repository.isPostLikedBy(postId: postId, uid: uid);

          // Assert
          expect(result, false);
        },
      );
    });
  });
}
