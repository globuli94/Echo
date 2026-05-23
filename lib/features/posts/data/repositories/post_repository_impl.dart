// lib/features/posts/data/repositories/post_repository_impl.dart
//
// PostRepositoryImpl — concrete implementation of [PostRepository].

import 'package:uuid/uuid.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/post_with_author.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required PostRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final PostRemoteDataSource _dataSource;

  @override
  Stream<List<PostWithAuthor>> streamFeed() {
    return _dataSource.streamFeed().asyncMap(_docsToPostsWithAuthors);
  }

  @override
  Future<FeedPage> fetchFeedPage({
    DateTime? before,
    int limit = 15,
  }) async {
    // Fetch one extra item to determine whether another page exists.
    final docs = await _dataSource.fetchFeedPage(
      before: before,
      limit: limit + 1,
    );

    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.take(limit).toList() : docs;

    final posts = await _docsToPostsWithAuthors(pageDocs);

    final DateTime? nextCursor =
        posts.isNotEmpty ? posts.last.post.createdAt : null;

    return FeedPage(posts: posts, hasMore: hasMore, nextCursor: nextCursor);
  }

  /// Resolves author profiles and maps raw Firestore document maps to
  /// [PostWithAuthor] entities.
  Future<List<PostWithAuthor>> _docsToPostsWithAuthors(
    List<Map<String, dynamic>> docs,
  ) async {
    final uniqueAuthorIds =
        docs.map((d) => d['authorId'] as String).toSet().toList();

    final profileFutures =
        uniqueAuthorIds.map((uid) => _dataSource.getAuthorProfile(uid));
    final profiles = await Future.wait(profileFutures);

    final profileMap = <String, Map<String, dynamic>?>{};
    for (var i = 0; i < uniqueAuthorIds.length; i++) {
      profileMap[uniqueAuthorIds[i]] = profiles[i];
    }

    return docs.map((doc) {
      final post = Post(
        postId: doc['postId'] as String,
        authorId: doc['authorId'] as String,
        content: doc['content'] as String,
        imageUrl: doc['imageUrl'] as String?,
        likeCount: (doc['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (doc['commentCount'] as num?)?.toInt() ?? 0,
        createdAt: doc['createdAt'] != null
            ? (doc['createdAt'] as dynamic).toDate() as DateTime
            : DateTime.now(),
      );

      final profile = profileMap[post.authorId];
      return PostWithAuthor(
        post: post,
        authorDisplayName:
            (profile?['displayName'] as String?) ?? 'Unknown User',
        authorAvatarUrl: profile?['avatarUrl'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> createPost({
    required String authorId,
    required String content,
    String? imagePath,
  }) async {
    final postId = const Uuid().v4();
    String? imageUrl;

    if (imagePath != null) {
      imageUrl = await _dataSource.uploadPostImage(
        uid: authorId,
        postId: postId,
        imagePath: imagePath,
      );
    }

    await _dataSource.createPost(
      postId: postId,
      authorId: authorId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String authorId,
  }) async {
    await _dataSource.deletePost(postId);
    await _dataSource.deletePostImage(uid: authorId, postId: postId);
  }
}
