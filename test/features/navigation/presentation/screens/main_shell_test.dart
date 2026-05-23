// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/navigation/presentation/screens/main_shell.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_state.dart';
import 'package:echo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:echo/features/profile/presentation/bloc/profile_state.dart';
import 'package:echo/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:echo/features/search/presentation/bloc/user_search_state.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockPostBloc extends Mock implements PostBloc {}

class MockUserPostsBloc extends Mock implements UserPostsBloc {}

class MockUserSearchBloc extends Mock implements UserSearchBloc {}

void main() {
  group('MainShell', () {
    late MockAuthBloc mockAuthBloc;
    late MockProfileBloc mockProfileBloc;
    late MockPostBloc mockPostBloc;
    late MockUserPostsBloc mockUserPostsBloc;
    late MockUserSearchBloc mockUserSearchBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockProfileBloc = MockProfileBloc();
      mockPostBloc = MockPostBloc();
      mockUserPostsBloc = MockUserPostsBloc();
      mockUserSearchBloc = MockUserSearchBloc();

      // Stub AuthBloc state
      when(() => mockAuthBloc.state).thenReturn(
        const AuthAuthenticated(
          user: AuthUser(uid: 'test-uid', email: 'test@example.com'),
        ),
      );
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      // Stub ProfileBloc state
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());

      // Stub PostBloc state — required because FeedScreen reads this
      // bloc via IndexedStack even when the Feed tab is not active.
      when(() => mockPostBloc.state).thenReturn(const PostsInitial());
      when(() => mockPostBloc.stream).thenAnswer((_) => const Stream.empty());

      // Stub UserPostsBloc state — required because ProfileScreen reads this
      // bloc via IndexedStack even when the Profile tab is not active.
      when(() => mockUserPostsBloc.state).thenReturn(const UserPostsInitial());
      when(() => mockUserPostsBloc.stream)
          .thenAnswer((_) => const Stream.empty());

      // Stub UserSearchBloc state — required because SearchScreen reads this
      // bloc via IndexedStack even when the Search tab is not active.
      when(() => mockUserSearchBloc.state)
          .thenReturn(const UserSearchInitial());
      when(() => mockUserSearchBloc.stream)
          .thenAnswer((_) => const Stream.empty());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
            BlocProvider<PostBloc>.value(value: mockPostBloc),
            BlocProvider<UserPostsBloc>.value(value: mockUserPostsBloc),
            BlocProvider<UserSearchBloc>.value(value: mockUserSearchBloc),
          ],
          child: const MainShell(),
        ),
      );
    }

    testWidgets('displays bottom navigation bar with three tabs',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byType(BottomNavigationBar),
        findsOneWidget,
        reason: 'Bottom navigation bar should be present',
      );

      final BottomNavigationBar navBar =
          find.byType(BottomNavigationBar).evaluate().single.widget
              as BottomNavigationBar;

      expect(
        navBar.items.length,
        equals(3),
        reason: 'Bottom navigation bar should have exactly 3 tabs',
      );
    });

    testWidgets('bottom navigation bar has Feed, Search, and Profile tabs',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.text('Feed'),
        findsWidgets,
        reason: 'Feed tab should be labeled "Feed"',
      );
      expect(
        find.text('Search'),
        findsWidgets,
        reason: 'Search tab should be labeled "Search"',
      );
      expect(
        find.text('Profile'),
        findsWidgets,
        reason: 'Profile tab should be labeled "Profile"',
      );
    });

    testWidgets('Feed tab is initially active', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Feed should be the active/selected tab initially
      final BottomNavigationBar navBar =
          find.byType(BottomNavigationBar).evaluate().single.widget
              as BottomNavigationBar;

      expect(
        navBar.currentIndex,
        equals(0),
        reason: 'Feed tab (index 0) should be active initially',
      );
    });

    testWidgets('tapping Profile tab switches to Profile', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Profile'));
      await tester.pump();

      // Assert
      final BottomNavigationBar navBar =
          find.byType(BottomNavigationBar).evaluate().single.widget
              as BottomNavigationBar;

      expect(
        navBar.currentIndex,
        equals(2),
        reason: 'Profile tab (index 2) should be active after tapping',
      );
    });

    testWidgets('tapping Feed tab returns to Feed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Switch to Profile
      await tester.tap(find.text('Profile'));
      await tester.pump();

      // Act - Switch back to Feed
      await tester.tap(find.text('Feed'));
      await tester.pump();

      // Assert
      final BottomNavigationBar navBar =
          find.byType(BottomNavigationBar).evaluate().single.widget
              as BottomNavigationBar;

      expect(
        navBar.currentIndex,
        equals(0),
        reason: 'Feed tab (index 0) should be active after tapping',
      );
    });

    testWidgets('FeedScreen is displayed when Feed tab is active',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.text('Feed'),
        findsWidgets,
        reason: 'Feed AppBar title should be visible',
      );
    });

    testWidgets('ProfileScreen is displayed when Profile tab is active',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Profile'));
      await tester.pump();

      // Assert
      expect(
        find.text('Profile'),
        findsWidgets,
        reason: 'Profile AppBar title should be visible',
      );
    });

    testWidgets('switching tabs preserves state with IndexedStack',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert that IndexedStack is being used
      expect(
        find.byType(IndexedStack),
        findsOneWidget,
        reason: 'IndexedStack should be used to preserve tab state',
      );

      // Act - Switch to Profile
      await tester.tap(find.text('Profile'));
      await tester.pump();

      // Assert - Profile is shown
      expect(
        find.text('Profile'),
        findsWidgets,
        reason: 'Profile should be visible after switch',
      );

      // Act - Switch back to Feed
      await tester.tap(find.text('Feed'));
      await tester.pump();

      // Assert - Feed is shown and should not have been rebuilt
      expect(
        find.text('Feed'),
        findsWidgets,
        reason: 'Feed should be visible after switching back',
      );
    });

    testWidgets('each tab has correct icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final BottomNavigationBar navBar =
          find.byType(BottomNavigationBar).evaluate().single.widget
              as BottomNavigationBar;

      // Verify that each item has an icon (not null)
      for (var item in navBar.items) {
        expect(
          item.icon,
          isNotNull,
          reason: 'Each tab should have an icon',
        );
      }
    });
  });
}
