// lib/features/navigation/presentation/screens/main_shell.dart
//
// MainShell — root authenticated screen with a bottom navigation bar.
// Uses IndexedStack to preserve each tab's widget subtree across switches.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/bloc/conversations/conversations_bloc.dart';
import '../../../chat/screens/conversations_screen.dart';
import '../../../feed/presentation/screens/feed_screen.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';

/// The main app scaffold shown to authenticated users.
///
/// Provides a four-tab bottom navigation bar (Feed · Search · Chat · Profile)
/// and preserves each tab's subtree via [IndexedStack].
class MainShell extends StatefulWidget {
  /// Creates a [MainShell].
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final notifState = context.watch<NotificationBloc>().state;
    final unreadCount =
        notifState is NotificationsLoaded ? notifState.unreadCount : 0;

    final authState = context.read<AuthBloc>().state;
    final currentUid =
        authState is AuthAuthenticated ? authState.user.uid : '';

    final screens = [
      const FeedScreen(),
      const SearchScreen(),
      ConversationsScreen(uid: currentUid),
      ProfileScreen(uid: currentUid),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Echo'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, convState) {
          int totalUnread = 0;
          if (convState is ConversationsLoaded) {
            for (final c in convState.conversations) {
              totalUnread += c.unreadCounts[currentUid] ?? 0;
            }
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Feed',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: totalUnread > 0
                    ? Badge.count(
                        count: totalUnread,
                        child: const Icon(Icons.chat_bubble_outline),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
