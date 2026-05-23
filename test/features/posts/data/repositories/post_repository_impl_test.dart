// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:echo/features/posts/data/repositories/post_repository_impl.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/domain/entities/post.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

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
  group('PostRepositoryImpl', () {
    late MockPostRemoteDataSource mockDataSource;
    late PostRepositoryImpl postRepository;

    setUp(() {
      mockDataSource = MockPostRemoteDataSource();
      postRepository = PostRepositoryImpl(dataSource: mockDataSource);
    });

    group('createPost', () {
      test('generates UUID, calls uploadPostImage, then dataSource.createPost()',
          () async {
        // Arrange
        const authorId = 'user-1';
        const content = 'Hello world';
        const imagePath = '/path/to/image.jpg';
        const imageUrl = 'https://example.com/image.jpg';

        when(() => mockDataSource.uploadPostImage(
          uid: authorId,
          postId: any(named: 'postId'),
          imagePath: imagePath,
        )).thenAnswer((_) async => imageUrl);

        when(() => mockDataSource.createPost(
          postId: any(named: 'postId'),
          authorId: authorId,
          content: content,
          imageUrl: imageUrl,
        )).thenAnswer((_) async {});

        // Act
        await postRepository.createPost(
          content: content,
          imagePath: imagePath,
          authorId: authorId,
        );

        // Assert
        verify(() => mockDataSource.uploadPostImage(
          uid: authorId,
          postId: any(named: 'postId'),
          imagePath: imagePath,
        )).called(1);

        verify(() => mockDataSource.createPost(
          postId: any(named: 'postId'),
          authorId: authorId,
          content: content,
          imageUrl: imageUrl,
        )).called(1);
      });

      test('does NOT call uploadPostImage when imagePath is null', () async {
        // Arrange
        const authorId = 'user-1';
        const content = 'Hello world';

        when(() => mockDataSource.createPost(
          postId: any(named: 'postId'),
          authorId: authorId,
          content: content,
          imageUrl: null,
        )).thenAnswer((_) async {});

        // Act
        await postRepository.createPost(
          content: content,
          imagePath: null,
          authorId: authorId,
        );

        // Assert
        verifyNever(() => mockDataSource.uploadPostImage(
          uid: any(named: 'uid'),
          postId: any(named: 'postId'),
          imagePath: any(named: 'imagePath'),
        ));

        verify(() => mockDataSource.createPost(
          postId: any(named: 'postId'),
          authorId: authorId,
          content: content,
          imageUrl: null,
        )).called(1);
      });
    });

    group('deletePost', () {
      test('calls dataSource.deletePost() and dataSource.deletePostImage()',
          () async {
        // Arrange
        const postId = 'post-1';
        const authorId = 'user-1';

        when(() => mockDataSource.deletePost(postId))
            .thenAnswer((_) async {});
        when(() => mockDataSource.deletePostImage(
          uid: authorId,
          postId: postId,
        )).thenAnswer((_) async {});

        // Act
        await postRepository.deletePost(
          postId: postId,
          authorId: authorId,
        );

        // Assert
        verify(() => mockDataSource.deletePost(postId)).called(1);
        verify(() => mockDataSource.deletePostImage(
          uid: authorId,
          postId: postId,
        )).called(1);
      });
    });

    group('streamFeed', () {
      test('emits PostWithAuthor list with correct authorDisplayName', () async {
        // Arrange - dataSource returns raw maps with author profiles
        when(() => mockDataSource.streamFeed()).thenAnswer((_) {
          return Stream.value([
            {
              'id': 'post-1',
              'postId': 'post-1',
              'authorId': 'user-1',
              'content': 'First post',
              'likeCount': 0,
              'commentCount': 0,
              // omit createdAt to let impl use DateTime.now()
            },
            {
              'id': 'post-2',
              'postId': 'post-2',
              'authorId': 'user-2',
              'content': 'Second post',
              'likeCount': 0,
              'commentCount': 0,
              // omit createdAt to let impl use DateTime.now()
            },
          ]);
        });

        when(() => mockDataSource.getAuthorProfile('user-1')).thenAnswer(
          (_) async => {'displayName': 'Alice'},
        );
        when(() => mockDataSource.getAuthorProfile('user-2')).thenAnswer(
          (_) async => {'displayName': 'Bob'},
        );

        // Act
        final stream = postRepository.streamFeed();

        // Assert
        expect(
          stream,
          emits(
            allOf(
              isA<List<PostWithAuthor>>().having(
                (list) => list.length,
                'length',
                2,
              ),
              isA<List<PostWithAuthor>>().having(
                (list) => list[0].authorDisplayName,
                'first author name',
                'Alice',
              ),
              isA<List<PostWithAuthor>>().having(
                (list) => list[1].authorDisplayName,
                'second author name',
                'Bob',
              ),
            ),
          ),
        );
      });
    });
  });
}
