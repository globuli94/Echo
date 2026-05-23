// lib/features/navigation/presentation/screens/main_shell.dart
//
// MainShell — root authenticated screen with a bottom navigation bar.
// Uses IndexedStack to preserve each tab's widget subtree across switches.

import 'package:flutter/material.dart';

import '../../../feed/presentation/screens/feed_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';

/// The main app scaffold shown to authenticated users.
///
/// Provides a three-tab bottom navigation bar (Feed · Search · Profile) and
/// preserves each tab's subtree via [IndexedStack].
class MainShell extends StatefulWidget {
  /// Creates a [MainShell].
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    FeedScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
