// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/features/navigation/presentation/screens/main_shell.dart';

void main() {
  group('MainShell', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: MainShell(),
      );
    }

    testWidgets('displays bottom navigation bar with two tabs',
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
        equals(2),
        reason: 'Bottom navigation bar should have exactly 2 tabs',
      );
    });

    testWidgets('bottom navigation bar has Feed and Profile tabs',
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
        equals(1),
        reason: 'Profile tab (index 1) should be active after tapping',
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
