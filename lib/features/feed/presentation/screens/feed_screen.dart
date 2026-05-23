// lib/features/feed/presentation/screens/feed_screen.dart
//
// FeedScreen — paginated post feed with pull-to-refresh, infinite scroll,
// empty state, and author profile navigation.

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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Null-safe read: PostBloc may not be in the tree during unit tests.
    context.read<PostBloc?>()?.add(const PostsFeedSubscribed());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Dispatches [PostsFeedLoadMore] when the user scrolls within 200 px of
  /// the bottom of the list.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<PostBloc?>()?.add(const PostsFeedLoadMore());
    }
  }

  /// Called by [RefreshIndicator]. Dispatches [PostsFeedRefreshed] and waits
  /// for the BLoC to leave the loading state before completing.
  Future<void> _onRefresh() async {
    final bloc = context.read<PostBloc?>();
    if (bloc == null) return;
    bloc.add(const PostsFeedRefreshed());
    await bloc.stream.firstWhere(
      (s) => s is PostsLoaded || s is PostsError,
    );
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
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: state.posts.isEmpty
                        ? _EmptyFeedView(scrollController: _scrollController)
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Extra item for the bottom loading indicator.
                            itemCount: state.posts.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.posts.length) {
                                return const _BottomLoadingIndicator();
                              }
                              return PostCard(
                                postWithAuthor: state.posts[index],
                                currentUserId: currentUserId,
                              );
                            },
                          ),
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

/// Shown when the feed has loaded but contains no posts. Uses a scrollable
/// layout so [RefreshIndicator] drag gestures still work on the empty state.
class _EmptyFeedView extends StatelessWidget {
  const _EmptyFeedView({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.post_add_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share something!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Loading spinner rendered as the last list item while a pagination request
/// is in flight.
class _BottomLoadingIndicator extends StatelessWidget {
  const _BottomLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
