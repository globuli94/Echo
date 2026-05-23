// lib/features/follow/presentation/screens/following_screen.dart
//
// FollowingScreen — lists all users that the viewed profile follows.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../bloc/follow_list_bloc.dart';
import '../bloc/follow_list_event.dart';
import '../bloc/follow_list_state.dart';

/// Screen that lists all users that [profileUid] follows.
///
/// A [FollowListBloc] must be provided above this widget in the tree
/// (via the route builder in [app_router.dart]).
class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key, required this.profileUid});

  /// The UID of the user whose following list is displayed.
  final String profileUid;

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<FollowListBloc>()
        .add(FollowingRequested(profileUid: widget.profileUid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: BlocBuilder<FollowListBloc, FollowListState>(
        builder: (context, state) {
          if (state is FollowListInitial || state is FollowListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FollowListError) {
            return Center(child: Text(state.message));
          }

          if (state is FollowListLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('Not following anyone yet'));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                return _UserRow(user: state.users[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _avatar(context),
      title: Text(user.displayName),
      onTap: () => context.push('/profile/${user.uid}'),
    );
  }

  Widget _avatar(BuildContext context) {
    final url = user.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url),
      );
    }
    return CircleAvatar(
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : '?',
      ),
    );
  }
}
