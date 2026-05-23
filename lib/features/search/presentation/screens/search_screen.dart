// lib/features/search/presentation/screens/search_screen.dart
//
// SearchScreen — shell tab for searching users by display name.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/user_search_bloc.dart';
import '../bloc/user_search_event.dart';
import '../bloc/user_search_state.dart';
import '../widgets/user_search_result_card.dart';

/// The user-search screen embedded in the [MainShell] navigation tab.
///
/// Holds a [TextEditingController] for the search field and a [Timer] for
/// debouncing Firestore queries.  Dispatches [UserSearchQueryChanged] after
/// a 500 ms idle period.
class SearchScreen extends StatefulWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  StreamSubscription<UserSearchState>? _subscription;
  UserSearchState _searchState = const UserSearchInitial();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<UserSearchBloc>();
    // Read initial state with a fallback so the screen renders gracefully
    // even in test environments where the mock state is not explicitly stubbed.
    try {
      _searchState = bloc.state;
    } catch (_) {
      _searchState = const UserSearchInitial();
    }
    _subscription = bloc.stream.listen((state) {
      if (mounted) setState(() => _searchState = state);
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<UserSearchBloc>().add(const UserSearchCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<UserSearchBloc>().add(UserSearchQueryChanged(query: value));
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    context.read<UserSearchBloc>().add(const UserSearchCleared());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search users…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    );
                  },
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = _searchState;

    if (state is UserSearchInitial) {
      return const SizedBox.shrink();
    }

    if (state is UserSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UserSearchLoaded) {
      final authState = context.read<AuthBloc>().state;
      final currentUid =
          authState is AuthAuthenticated ? authState.user.uid : '';
      return ListView.separated(
        itemCount: state.results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = state.results[index];
          return UserSearchResultCard(
            user: user,
            currentUid: currentUid,
            onTap: () => context.go('/profile/${user.uid}'),
          );
        },
      );
    }

    if (state is UserSearchEmpty) {
      return Center(
        child: Text(
          'No results for "${_controller.text}"',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (state is UserSearchFailure) {
      return Center(
        child: Text(
          state.error,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
