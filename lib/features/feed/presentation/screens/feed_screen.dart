// lib/features/feed/presentation/screens/feed_screen.dart
//
// FeedScreen — live post feed with FAB to create a new post.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../posts/presentation/bloc/post_bloc.dart';
import '../../../posts/presentation/bloc/post_event.dart';
import '../../../posts/presentation/bloc/post_state.dart';
import '../../../posts/presentation/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Null-safe read: PostBloc may not be in the tree during unit tests.
    context.read<PostBloc?>()?.add(const PostsFeedSubscribed());
  }

  @override
  Widget build(BuildContext context) {
    final postBloc = context.read<PostBloc?>();
    final authState = context.read<AuthBloc?>()?.state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: postBloc == null
          ? const SizedBox.shrink()
          : BlocBuilder<PostBloc, PostState>(
              bloc: postBloc,
              builder: (context, state) {
                if (state is PostsInitial || state is PostsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PostsError) {
                  return Center(child: Text(state.message));
                }
                if (state is PostsLoaded) {
                  if (state.posts.isEmpty) {
                    return const Center(child: Text('No posts yet'));
                  }
                  return ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        postWithAuthor: state.posts[index],
                        currentUserId: currentUserId,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      floatingActionButton: postBloc == null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/create-post'),
              child: const Icon(Icons.add),
            ),
    );
  }
}
