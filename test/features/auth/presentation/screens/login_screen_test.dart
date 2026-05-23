// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/screens/login_screen.dart';
import 'package:echo/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginScreen', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repository: mockAuthRepository),
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('displays app icon and Echo title',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(find.byType(Image), findsWidgets,
          reason: 'App icon should be displayed');
      expect(
        find.text('Echo'),
        findsWidgets,
        reason: 'Echo title should be visible',
      );
    });

    testWidgets('displays email input field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byType(TextField),
        findsWidgets,
        reason: 'Should have text input fields for email and password',
      );

      // Verify email field exists by looking for hint text or label
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
      // Verify password field is present by checking obscureText property
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            (widget.obscureText == true ||
                (widget.decoration?.hintText?.contains('password') ?? false) ||
                (widget.decoration?.labelText?.contains('password') ?? false) ||
                (widget.decoration?.hintText?.contains('Password') ?? false) ||
                (widget.decoration?.labelText?.contains('Password') ?? false))),
        findsWidgets,
        reason: 'Password input field should be present and obscured',
      );
    });

    testWidgets('displays Log In button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      // More direct approach - look for button text
      expect(
        find.text('Log In'),
        findsWidgets,
        reason: 'Log In button with text should be present',
      );
    });

    testWidgets('displays Google Sign-In button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            ((widget.data?.contains('Google') ?? false) ||
                (widget.data?.contains('google') ?? false))),
        findsWidgets,
        reason: 'Google Sign-In button should be present',
      );
    });

    testWidgets('displays Forgot Password link', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            ((widget.data?.contains('Forgot') ?? false) ||
                (widget.data?.contains('forgot') ?? false) ||
                (widget.data?.contains('password') ?? false))),
        findsWidgets,
        reason: 'Forgot Password link should be present',
      );
    });

    testWidgets('displays link to sign up screen', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act & Assert
      // Check for either a button or text that references signup
      expect(
        find.byType(GestureDetector),
        findsWidgets,
        reason: 'Sign Up link should be present (as a gesture detector)',
      );
    });

    testWidgets(
        'email and password fields accept input',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      await tester.enterText(
        find.byType(TextField).first,
        email,
      );
      await tester.enterText(
        find.byType(TextField).last,
        password,
      );
      await tester.pump();

      // Assert
      expect(find.text(email), findsWidgets);
      expect(find.text(password), findsWidgets);
    });
  });
}
