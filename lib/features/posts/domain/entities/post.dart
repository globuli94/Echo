// lib/features/posts/domain/entities/post.dart
//
// Post — pure Dart domain entity representing a social post.

import 'package:equatable/equatable.dart';

/// Represents a single post in the domain layer.
class Post extends Equatable {
  const Post({
    required this.postId,
    required this.authorId,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.imageUrl,
  });

  final String postId;
  final String authorId;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [postId, authorId, content, imageUrl, likeCount, commentCount, createdAt];
}
