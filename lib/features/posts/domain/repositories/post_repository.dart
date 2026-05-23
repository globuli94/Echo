// lib/features/posts/domain/repositories/post_repository.dart
//
// PostRepository — abstract interface for post operations.

import 'package:equatable/equatable.dart';

import '../entities/post_with_author.dart';

/// A single page of feed results returned by [PostRepository.fetchFeedPage].
class FeedPage extends Equatable {
  /// Creates a [FeedPage].
  const FeedPage({
    required this.posts,
    required this.hasMore,
    this.nextCursor,
  });

  /// The posts in this page.
  final List<PostWithAuthor> posts;

  /// Whether more posts may be available after this page.
  final bool hasMore;

  /// Cursor for the next page — the [DateTime] of the oldest post in this
  /// batch. Pass as [before] to [PostRepository.fetchFeedPage] to load the
  /// next page.
  final DateTime? nextCursor;

  @override
  List<Object?> get props => [posts, hasMore, nextCursor];
}

abstract class PostRepository {
  /// Streams the full feed ordered by [createdAt] DESC with author info joined.
  Stream<List<PostWithAuthor>> streamFeed();

  /// Fetches a single page of up to [limit] posts ordered by [createdAt] DESC.
  ///
  /// Omit [before] to start from the most recent post. Pass
  /// [FeedPage.nextCursor] from a previous call to continue from the last
  /// item.
  Future<FeedPage> fetchFeedPage({DateTime? before, int limit = 15});

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
