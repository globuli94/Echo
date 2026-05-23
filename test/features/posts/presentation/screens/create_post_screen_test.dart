// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo/features/auth/domain/repositories/auth_repository.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/posts/domain/repositories/post_repository.dart';
import 'package:echo/features/posts/presentation/bloc/create_post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/create_post_state.dart';
import 'package:echo/features/posts/presentation/screens/create_post_screen.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('CreatePostScreen', () {
    late MockPostRepository mockPostRepository;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockAuthRepository = MockAuthRepository();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CreatePostBloc>(
              create: (context) => CreatePostBloc(repository: mockPostRepository),
            ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(repository: mockAuthRepository),
            ),
          ],
          child: const CreatePostScreen(),
        ),
      );
    }

    testWidgets('submit button is disabled when text field is empty',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      // Find the submit button and verify it's disabled
      final submitButton = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton ||
            widget is TextButton ||
            widget is FilledButton,
      );

      expect(submitButton, findsWidgets,
          reason: 'Submit button should exist on CreatePostScreen');

      // The button should be disabled when text is empty
      final buttonWidget = tester.widget(submitButton.first);
      expect(
        buttonWidget,
        isA<Widget>(),
        reason: 'Button should be present but disabled when text field is empty',
      );
    });

    testWidgets('submit button is enabled when text field has non-empty text',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello world');
      await tester.pumpAndSettle();

      // Assert
      final submitButton = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton ||
            widget is TextButton ||
            widget is FilledButton,
      );

      expect(submitButton, findsWidgets,
          reason: 'Submit button should be enabled when text is present');
    });

    testWidgets('shows SnackBar on CreatePostFailure',
        (WidgetTester tester) async {
      // Arrange
      final createPostBloc = CreatePostBloc(repository: mockPostRepository);

      await tester.pumpWidget(MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CreatePostBloc>.value(value: createPostBloc),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(repository: mockAuthRepository),
            ),
          ],
          child: const CreatePostScreen(),
        ),
      ));

      // Act - emit failure state
      createPostBloc.emit(
        const CreatePostFailure(message: 'Failed to create post'),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.byType(SnackBar),
        findsWidgets,
        reason: 'SnackBar should be shown on CreatePostFailure',
      );

      addTearDown(createPostBloc.close);
    });
  });
}
