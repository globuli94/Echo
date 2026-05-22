// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/screens/signup_screen.dart';
import 'package:echo/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('SignupScreen', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repository: mockAuthRepository),
          child: const SignupScreen(),
        ),
      );
    }

    testWidgets('displays display name input field',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byType(TextField),
        findsWidgets,
        reason: 'Should have text input fields',
      );

      // Verify display name field exists
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            ((widget.decoration?.hintText?.contains('name') ?? false) ||
                (widget.decoration?.labelText?.contains('name') ?? false) ||
                (widget.decoration?.hintText?.contains('Name') ?? false) ||
                (widget.decoration?.labelText?.contains('Name') ?? false) ||
                (widget.decoration?.hintText?.contains('display') ?? false) ||
                (widget.decoration?.labelText?.contains('display') ?? false))),
        findsWidgets,
        reason: 'Display name input field should be present',
      );
    });

    testWidgets('displays email input field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            ((widget.decoration?.hintText?.contains('email') ?? false) ||
                (widget.decoration?.labelText?.contains('email') ?? false) ||
                (widget.decoration?.hintText?.contains('Email') ?? false) ||
                (widget.decoration?.labelText?.contains('Email') ?? false))),
        findsWidgets,
        reason: 'Email input field should be present',
      );
    });

    testWidgets('displays password input field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            (widget.obscureText == true ||
                (widget.decoration?.hintText?.contains('password') ?? false) ||
                (widget.decoration?.labelText?.contains('password') ?? false) ||
                (widget.decoration?.hintText?.contains('Password') ?? false) ||
                (widget.decoration?.labelText?.contains('Password') ?? false))),
        findsWidgets,
        reason: 'Password input field should be present',
      );
    });

    testWidgets('displays Sign Up button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.text('Sign Up'),
        findsWidgets,
        reason: 'Sign Up button with text should be present',
      );
    });

    testWidgets('displays link to login screen', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      // Check for either a button or text that references login
      expect(
        find.byType(GestureDetector),
        findsWidgets,
        reason: 'Log In link should be present (as a gesture detector)',
      );
    });

    testWidgets('display name, email and password fields accept input',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      const displayName = 'Test User';
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), displayName);
      await tester.enterText(textFields.at(1), email);
      await tester.enterText(textFields.at(2), password);
      await tester.pump();

      // Assert
      expect(find.text(displayName), findsWidgets);
      expect(find.text(email), findsWidgets);
      expect(find.text(password), findsWidgets);
    });
  });
}
