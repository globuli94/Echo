// Copyright (c) 2024. All rights reserved.
// Test suite for MainShell navigation.

import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/navigation/presentation/screens/main_shell.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_event.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_event.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_state.dart';
import 'package:echo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:echo/features/profile/presentation/bloc/profile_event.dart';
import 'package:echo/features/profile/presentation/bloc/profile_state.dart';
import 'package:echo/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:echo/features/search/presentation/bloc/user_search_event.dart';
import 'package:echo/features/search/presentation/bloc/user_search_state.dart';
import 'package:echo/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

class MockUserPostsBloc extends MockBloc<UserPostsEvent, UserPostsState>
    implements UserPostsBloc {}

class MockUserSearchBloc extends MockBloc<UserSearchEvent, UserSearchState>
    implements UserSearchBloc {}

void main() {
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

  group('MainShell Navigation', () {
    testWidgets('shows three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('tapping Search tab shows SearchScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });
}
