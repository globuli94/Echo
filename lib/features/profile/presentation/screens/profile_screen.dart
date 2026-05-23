// lib/features/profile/presentation/screens/profile_screen.dart
//
// ProfileScreen — shows a user's public profile. When [uid] is null the screen
// displays the currently authenticated user's own profile.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
            // Determine isOwner from authState since ProfileUpdating doesn't
            // carry it (we need to keep showing the right UI during updates).
            final authState = context.read<AuthBloc>().state;
            isOwner = authState is AuthAuthenticated &&
                profile.uid == authState.user.uid;
            isUpdating = true;
          } else {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AvatarWidget(
                      profile: profile,
                      isOwner: isOwner,
                      onUpload: () => _pickAndUploadAvatar(profile.uid),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio.isEmpty ? 'No bio yet' : profile.bio,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.grid_on, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.postCount} posts',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (isOwner) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.push('/edit-profile'),
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ],
                ),
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
