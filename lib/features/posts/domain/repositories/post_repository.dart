// lib/features/posts/domain/repositories/post_repository.dart
//
// PostRepository — abstract interface for post operations.

import '../entities/post_with_author.dart';

abstract class PostRepository {
  /// Streams the full feed ordered by [createdAt] DESC with author info joined.
  Stream<List<PostWithAuthor>> streamFeed();

  /// Creates a new post. Uploads image to Storage first if [imagePath] provided.
  Future<void> createPost({
    required String authorId,
    required String content,
    String? imagePath,
  });

  /// Deletes post document and its Storage image (if any).
  /// [authorId] is needed to construct the Storage path `posts/{authorId}/{postId}`.
  Future<void> deletePost({
    required String postId,
    required String authorId,
  });
}
