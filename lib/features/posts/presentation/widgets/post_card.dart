// lib/features/posts/presentation/widgets/post_card.dart
//
// PostCard — displays a single post with author info, content, and image.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/post_with_author.dart';
import '../../domain/repositories/post_repository.dart';
import '../bloc/like_bloc.dart';
import '../bloc/like_event.dart';
import '../bloc/like_state.dart';
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
            const SizedBox(height: 8),
            BlocProvider<LikeBloc>(
              key: ValueKey('like_${post.postId}'),
              create: (ctx) =>
                  LikeBloc(repository: ctx.read<PostRepository>())
                    ..add(LikeStatusFetched(
                      postId: post.postId,
                      currentUserId: currentUserId,
                      initialCount: post.likeCount,
                    )),
              child: _LikeButton(
                postId: post.postId,
                currentUserId: currentUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.postId,
    required this.currentUserId,
  });

  final String postId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LikeBloc, LikeState>(
      builder: (context, state) {
        if (state is LikeLoading || state is LikeInitial) {
          return const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          );
        }

        if (state is LikeLoaded) {
          return Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  state.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: state.isLiked
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () {
                  context.read<LikeBloc>().add(
                        LikeToggleRequested(
                          postId: postId,
                          currentUserId: currentUserId,
                          isCurrentlyLiked: state.isLiked,
                          currentCount: state.likeCount,
                        ),
                      );
                },
              ),
              const SizedBox(width: 4),
              Text('${state.likeCount}'),
            ],
          );
        }

        // LikeError — show disabled heart
        return const Row(
          children: [
            Icon(Icons.favorite_border),
            SizedBox(width: 4),
            Text('—'),
          ],
        );
      },
    );
  }
}
