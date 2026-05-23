// lib/features/profile/presentation/screens/profile_screen.dart
//
// ProfileScreen — shows a user's public profile, their posts, and allows
// navigating to their followers/following lists. Owners can sign out.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../../../posts/presentation/bloc/user_posts_bloc.dart';
import '../../../posts/presentation/bloc/user_posts_event.dart';
import '../../../posts/presentation/bloc/user_posts_state.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Screen that renders a user's public profile.
///
/// Pass [uid] to display another user's profile (read-only).
/// Omit [uid] (null) to display the authenticated user's own profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.uid});

  final String? uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final viewerUid = authState.user.uid;
    final targetUid = widget.uid ?? viewerUid;
    context.read<ProfileBloc>().add(
          ProfileLoadRequested(uid: targetUid, viewerUid: viewerUid),
        );
    context
        .read<UserPostsBloc>()
        .add(UserPostsLoadRequested(authorId: targetUid));
  }

  Future<void> _pickAndUploadAvatar(String uid) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    context.read<ProfileBloc>().add(
          ProfileAvatarUploadRequested(uid: uid, imagePath: picked.path),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        leading: context.canPop() ? const BackButton() : null,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileFailure) {
            return Center(child: Text(state.error));
          }

          final UserProfile profile;
          final bool isOwner;
          final bool isUpdating;

          if (state is ProfileLoaded) {
            profile = state.profile;
            isOwner = state.isOwner;
            isUpdating = false;
          } else if (state is ProfileUpdating) {
            profile = state.profile;
            final authState = context.read<AuthBloc>().state;
            isOwner = authState is AuthAuthenticated &&
                profile.uid == authState.user.uid;
            isUpdating = true;
          } else {
            return const SizedBox.shrink();
          }

          final authState = context.read<AuthBloc>().state;
          final currentUserId =
              authState is AuthAuthenticated ? authState.user.uid : '';

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _AvatarWidget(
                            profile: profile,
                            isOwner: isOwner,
                            onUpload: () =>
                                _pickAndUploadAvatar(profile.uid),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.displayName,
                            style:
                                Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio.isEmpty
                                ? 'No bio yet'
                                : profile.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatItem(
                                icon: Icons.grid_on,
                                label: '${profile.postCount} posts',
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: () => context
                                    .push('/followers/${profile.uid}'),
                                child: _StatItem(
                                  icon: Icons.people,
                                  label:
                                      '${profile.followerCount} followers',
                                ),
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: () => context
                                    .push('/following/${profile.uid}'),
                                child: _StatItem(
                                  icon: Icons.person_add,
                                  label:
                                      '${profile.followingCount} following',
                                ),
                              ),
                            ],
                          ),
                          if (isOwner) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () =>
                                  context.push('/edit-profile'),
                              child: const Text('Edit Profile'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => context
                                  .read<AuthBloc>()
                                  .add(const SignOutRequested()),
                              child: const Text('Sign Out'),
                            ),
                          ] else ...[
                            const SizedBox(height: 24),
                            _FollowButton(profile: profile),
                          ],
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Posts',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  _UserPostsSliver(currentUserId: currentUserId),
                ],
              ),
              if (isUpdating)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}

/// Sliver that renders the user's posts list using [UserPostsBloc].
class _UserPostsSliver extends StatelessWidget {
  const _UserPostsSliver({required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPostsBloc, UserPostsState>(
      builder: (context, state) {
        if (state is UserPostsInitial || state is UserPostsLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is UserPostsError) {
          return SliverToBoxAdapter(
            child: Center(child: Text(state.message)),
          );
        }

        if (state is UserPostsLoaded) {
          if (state.posts.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No posts yet')),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final p = state.posts[index];
                return _PostListItem(
                  content: p.post.content,
                  imageUrl: p.post.imageUrl,
                  createdAt: p.post.createdAt,
                );
              },
              childCount: state.posts.length,
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

/// Compact post card used inside the profile posts list.
class _PostListItem extends StatelessWidget {
  const _PostListItem({
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM d · h:mm a').format(createdAt.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(content),
            if (imageUrl != null) ...[
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowBloc, FollowState>(
      listener: (context, state) {
        if (state is FollowStatusLoaded) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<ProfileBloc>().add(
                  ProfileLoadRequested(
                    uid: profile.uid,
                    viewerUid: authState.user.uid,
                  ),
                );
          }
        }
      },
      builder: (context, state) {
        if (state is FollowInitial || state is FollowLoading) {
          return const SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: null,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is FollowActionInProgress) {
          return SizedBox(
            width: 120,
            child: state.status.isFollowing
                ? OutlinedButton(
                    onPressed: null,
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ElevatedButton(
                    onPressed: null,
                    child: const SizedBox(
                      width: 16,
                      height: 16,
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
        final currentUid =
            authState is AuthAuthenticated ? authState.user.uid : '';

        if (isFollowing) {
          return OutlinedButton(
            onPressed: () => context.read<FollowBloc>().add(
                  UnfollowRequested(
                    currentUid: currentUid,
                    targetUid: profile.uid,
                  ),
                ),
            child: const Text('Unfollow'),
          );
        }

        return ElevatedButton(
          onPressed: () => context.read<FollowBloc>().add(
                FollowRequested(
                  currentUid: currentUid,
                  targetUid: profile.uid,
                ),
              ),
          child: const Text('Follow'),
        );
      },
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.profile,
    required this.isOwner,
    required this.onUpload,
  });

  final UserProfile profile;
  final bool isOwner;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
    final initials = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : '?';

    Widget avatar;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 48,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    } else {
      avatar = CircleAvatar(
        radius: 48,
        child: Text(
          initials,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    if (!isOwner) return avatar;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        avatar,
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: onUpload,
          tooltip: 'Upload avatar',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
