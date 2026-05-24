// lib/features/posts/presentation/widgets/like_button.dart
//
// LikeButton — consumes LikeBloc to render a like toggle with count.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/like_bloc.dart';
import '../bloc/like_event.dart';
import '../bloc/like_state.dart';

/// Like/unlike toggle button with count. Consumes [LikeBloc] from context.
/// Must be used inside a [BlocProvider<LikeBloc>] ancestor.
class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  /// The ID of the post this button is associated with.
  final String postId;

  /// The UID of the currently authenticated user.
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
