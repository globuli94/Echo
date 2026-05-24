// lib/features/search/presentation/widgets/user_search_result_card.dart
//
// UserSearchResultCard — a list-item card representing a single search result.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../follow/domain/repositories/follow_repository.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// A card widget that displays a single user search result.
///
/// Provides its own per-item [FollowBloc] when [FollowRepository] is available
/// in the widget tree, so each card in the results list manages its own
/// independent follow state.  The inner [_UserSearchResultCardContent] widget
/// only consumes — it never provides — the [FollowBloc].
///
/// When [FollowRepository] is absent (e.g. in unit tests that do not wire up
/// the follow layer), the follow button is omitted and the card gracefully
/// renders avatar + display name only.
class UserSearchResultCard extends StatelessWidget {
  /// Creates a [UserSearchResultCard] for the given [user].
  const UserSearchResultCard({
    super.key,
    required this.user,
    required this.currentUid,
    required this.onTap,
  });

  /// The user profile to display.
  final UserProfile user;

  /// The UID of the currently authenticated user.
  final String currentUid;

  /// Called when the user taps anywhere on the card except the follow button.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Use nullable read so the card renders gracefully when FollowRepository
    // is not wired up (e.g. screen-level widget tests).
    final followRepo = context.read<FollowRepository?>();

    // Provide a per-item FollowBloc only when the repository is available and
    // we are viewing someone else's profile.
    if (followRepo != null && user.uid != currentUid) {
      return BlocProvider<FollowBloc>(
        key: ValueKey(user.uid),
        create: (ctx) => FollowBloc(
          repository: followRepo,
        )..add(FollowStatusSubscribed(
            currentUid: currentUid,
            targetUid: user.uid,
          )),
        child: _UserSearchResultCardContent(
          user: user,
          currentUid: currentUid,
          onTap: onTap,
          showFollowButton: true,
        ),
      );
    }

    return _UserSearchResultCardContent(
      user: user,
      currentUid: currentUid,
      onTap: onTap,
      showFollowButton: followRepo != null,
    );
  }
}

/// Internal content widget that consumes [FollowBloc] when available.
class _UserSearchResultCardContent extends StatelessWidget {
  const _UserSearchResultCardContent({
    required this.user,
    required this.currentUid,
    required this.onTap,
    required this.showFollowButton,
  });

  final UserProfile user;
  final String currentUid;
  final VoidCallback onTap;

  /// Whether to render the follow/unfollow button.
  ///
  /// `false` when [FollowRepository] is not in scope (e.g. unit tests).
  final bool showFollowButton;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(avatarUrl: user.avatarUrl, displayName: user.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.displayName,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showFollowButton && user.uid != currentUid)
              _FollowButton(user: user, currentUid: currentUid),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar using [CachedNetworkImage] with a [CircleAvatar] placeholder.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.displayName});

  /// The remote URL of the avatar image, or `null` if unavailable.
  final String? avatarUrl;

  /// Display name used as a fallback initial inside the placeholder.
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 24,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.errorContainer,
        child: Text(
          initial,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}

/// Follow/Unfollow button consuming the per-card [FollowBloc].
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.user, required this.currentUid});

  final UserProfile user;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state is FollowInitial || state is FollowLoading) {
          return const SizedBox(
            width: 96,
            child: ElevatedButton(
              onPressed: null,
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is FollowActionInProgress) {
          return SizedBox(
            width: 96,
            child: state.status.isFollowing
                ? OutlinedButton(
                    onPressed: null,
                    child: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ElevatedButton(
                    onPressed: null,
                    child: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          );
        }

        final bool isFollowing;
        if (state is FollowStatusLoaded) {
          isFollowing = state.status.isFollowing;
        } else if (state is FollowFailure && state.lastKnownStatus != null) {
          isFollowing = state.lastKnownStatus!.isFollowing;
        } else {
          isFollowing = false;
        }

        final authState = context.read<AuthBloc>().state;
        final uid =
            authState is AuthAuthenticated ? authState.user.uid : currentUid;

        if (isFollowing) {
          return SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: () => context.read<FollowBloc>().add(
                    UnfollowRequested(
                      currentUid: uid,
                      targetUid: user.uid,
                    ),
                  ),
              child: const Text('Unfollow'),
            ),
          );
        }

        final actorDisplayName = authState is AuthAuthenticated
            ? (authState.user.displayName ?? '')
            : '';

        return SizedBox(
          width: 96,
          child: ElevatedButton(
            onPressed: () => context.read<FollowBloc>().add(
                  FollowRequested(
                    currentUid: uid,
                    targetUid: user.uid,
                    actorDisplayName: actorDisplayName,
                  ),
                ),
            child: const Text('Follow'),
          ),
        );
      },
    );
  }
}
