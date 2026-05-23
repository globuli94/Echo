// lib/features/posts/domain/entities/post_with_author.dart
//
// PostWithAuthor — domain entity combining a Post with its author profile.

import 'package:equatable/equatable.dart';

import 'post.dart';

/// A [Post] enriched with author display information.
class PostWithAuthor extends Equatable {
  const PostWithAuthor({
    required this.post,
    required this.authorDisplayName,
    this.authorAvatarUrl,
  });

  final Post post;
  final String authorDisplayName;
  final String? authorAvatarUrl;

  @override
  List<Object?> get props => [post, authorDisplayName, authorAvatarUrl];
}
