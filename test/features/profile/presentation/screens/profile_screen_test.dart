// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/features/profile/presentation/screens/profile_screen.dart';

void main() {
  group('ProfileScreen', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: ProfileScreen(),
      );
    }

    testWidgets('displays Scaffold with Profile AppBar title',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'ProfileScreen should render a Scaffold',
      );

      expect(
        find.text('Profile'),
        findsWidgets,
        reason: 'ProfileScreen should have AppBar titled "Profile"',
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
        reason: 'ProfileScreen should have an AppBar',
      );

      // The screen should be minimal with just scaffold and appbar
      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'ProfileScreen should have a Scaffold',
      );
    });
  });
}
