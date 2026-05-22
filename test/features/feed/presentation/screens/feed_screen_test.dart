// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/features/feed/presentation/screens/feed_screen.dart';

void main() {
  group('FeedScreen', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: FeedScreen(),
      );
    }

    testWidgets('displays Scaffold with Feed AppBar title',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'FeedScreen should render a Scaffold',
      );

      expect(
        find.text('Feed'),
        findsWidgets,
        reason: 'FeedScreen should have AppBar titled "Feed"',
      );
    });

    testWidgets('is an empty placeholder screen', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      // Should have Scaffold and AppBar, but no real content
      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason: 'FeedScreen should have an AppBar',
      );

      // The screen should be minimal with just scaffold and appbar
      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'FeedScreen should have a Scaffold',
      );
    });
  });
}
