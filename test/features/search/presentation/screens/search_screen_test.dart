// Copyright (c) 2024. All rights reserved.
// Test suite for SearchScreen widget.

import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:echo/features/search/presentation/bloc/user_search_event.dart';
import 'package:echo/features/search/presentation/bloc/user_search_state.dart';
import 'package:echo/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSearchBloc extends MockBloc<UserSearchEvent, UserSearchState>
    implements UserSearchBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockUserSearchBloc mockUserSearchBloc;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockUserSearchBloc = MockUserSearchBloc();
    mockAuthBloc = MockAuthBloc();

    // Stub AuthBloc state to avoid null state errors
    when(() => mockAuthBloc.state).thenReturn(
      const AuthAuthenticated(
        user: AuthUser(uid: 'test-uid', email: 'test@example.com'),
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UserSearchBloc>.value(value: mockUserSearchBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const SearchScreen(),
      ),
    );
  }

  group('SearchScreen', () {
    testWidgets('shows CircularProgressIndicator on UserSearchLoading',
        (WidgetTester tester) async {
      when(() => mockUserSearchBloc.state).thenReturn(UserSearchLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows result cards on UserSearchLoaded',
        (WidgetTester tester) async {
      final mockUser = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      when(() => mockUserSearchBloc.state).thenReturn(
        UserSearchLoaded(results: [mockUser]),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows empty-state text on UserSearchEmpty',
        (WidgetTester tester) async {
      when(() => mockUserSearchBloc.state).thenReturn(UserSearchEmpty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('No results'), findsOneWidget);
    });

    testWidgets('shows nothing special on UserSearchInitial',
        (WidgetTester tester) async {
      when(() => mockUserSearchBloc.state).thenReturn(UserSearchInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });
  });
}
