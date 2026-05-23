// lib/features/posts/presentation/widgets/post_card.dart
//
// PostCard — displays a single post with author info, content, and image.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/post_with_author.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.postWithAuthor,
    required this.currentUserId,
  });

  final PostWithAuthor postWithAuthor;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final post = postWithAuthor.post;
    final formattedDate =
        DateFormat('MMM d · h:mm a').format(post.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/profile/${post.authorId}'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: postWithAuthor.authorAvatarUrl != null
                              ? CachedNetworkImageProvider(
                                  postWithAuthor.authorAvatarUrl!)
                              : null,
                          child: postWithAuthor.authorAvatarUrl == null
                              ? Text(
                                  postWithAuthor.authorDisplayName.isNotEmpty
                                      ? postWithAuthor.authorDisplayName[0]
                                          .toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postWithAuthor.authorDisplayName,
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (post.authorId == currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete post',
                    onPressed: () {
                      context.read<PostBloc>().add(
                            PostDeleteRequested(
                              postId: post.postId,
                              authorId: post.authorId,
                            ),
                          );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
