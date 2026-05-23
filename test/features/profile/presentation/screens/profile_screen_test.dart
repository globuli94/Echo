// SPDX-License-Identifier: MIT
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_bloc.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_event.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_state.dart';
import 'package:echo/features/posts/presentation/bloc/post_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/post_event.dart';
import 'package:echo/features/posts/presentation/bloc/post_state.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_event.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_state.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:echo/features/profile/presentation/bloc/profile_event.dart';
import 'package:echo/features/profile/presentation/bloc/profile_state.dart';
import 'package:echo/features/profile/presentation/screens/profile_screen.dart';
import 'package:echo/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:echo/features/search/presentation/bloc/user_search_event.dart';
import 'package:echo/features/search/presentation/bloc/user_search_state.dart';
import 'package:echo/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSearchBloc extends MockBloc<UserSearchEvent, UserSearchState>
    implements UserSearchBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockUserPostsBloc extends MockBloc<UserPostsEvent, UserPostsState>
    implements UserPostsBloc {}

class MockFollowListBloc extends MockBloc<FollowListEvent, FollowListState>
    implements FollowListBloc {}

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

void main() {
  group('ProfileScreen - Back Navigation', () {
    late MockUserSearchBloc mockSearchBloc;
    late MockAuthBloc mockAuthBloc;
    late MockProfileBloc mockProfileBloc;
    late MockUserPostsBloc mockUserPostsBloc;
    late MockFollowListBloc mockFollowListBloc;
    late MockPostBloc mockPostBloc;

    const otherUid = 'other-uid';

    final mockUser = UserProfile(
      uid: otherUid,
      displayName: 'Alice',
      bio: 'Test bio',
      avatarUrl: null,
      postCount: 5,
    );

    setUp(() {
      mockSearchBloc = MockUserSearchBloc();
      mockAuthBloc = MockAuthBloc();
      mockProfileBloc = MockProfileBloc();
      mockUserPostsBloc = MockUserPostsBloc();
      mockFollowListBloc = MockFollowListBloc();
      mockPostBloc = MockPostBloc();

      // Stub auth bloc with stream
      when(() => mockAuthBloc.state).thenReturn(
        const AuthAuthenticated(
          user: AuthUser(uid: 'current-uid', email: 'test@example.com'),
        ),
      );
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthAuthenticated(
            user: AuthUser(uid: 'current-uid', email: 'test@example.com'),
          ),
        ]),
        initialState: const AuthAuthenticated(
          user: AuthUser(uid: 'current-uid', email: 'test@example.com'),
        ),
      );

      // Stub profile bloc with stream
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([const ProfileInitial()]),
        initialState: const ProfileInitial(),
      );

      // Stub user posts bloc with stream
      when(() => mockUserPostsBloc.state)
          .thenReturn(const UserPostsInitial());
      whenListen(
        mockUserPostsBloc,
        Stream.fromIterable([const UserPostsInitial()]),
        initialState: const UserPostsInitial(),
      );

      // Stub follow list bloc with stream
      when(() => mockFollowListBloc.state)
          .thenReturn(const FollowListInitial());
      whenListen(
        mockFollowListBloc,
        Stream.fromIterable([const FollowListInitial()]),
        initialState: const FollowListInitial(),
      );

      // Stub post bloc with stream
      when(() => mockPostBloc.state).thenReturn(const PostsInitial());
      whenListen(
        mockPostBloc,
        Stream.fromIterable([const PostsInitial()]),
        initialState: const PostsInitial(),
      );
    });

    testWidgets(
        'shows back button when ProfileScreen is pushed from search results',
        (WidgetTester tester) async {
      // Stub search bloc
      when(() => mockSearchBloc.state)
          .thenReturn(UserSearchLoaded(results: [mockUser]));
      whenListen(
        mockSearchBloc,
        Stream.fromIterable([UserSearchLoaded(results: [mockUser])]),
        initialState: UserSearchLoaded(results: [mockUser]),
      );

      // Build test app with search and profile routes
      final router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(
            path: '/search',
            builder: (ctx, state) => MultiBlocProvider(
              providers: [
                BlocProvider<UserSearchBloc>.value(value: mockSearchBloc),
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
              ],
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/:uid',
            builder: (ctx, state) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                BlocProvider<UserPostsBloc>.value(value: mockUserPostsBloc),
                BlocProvider<FollowListBloc>.value(value: mockFollowListBloc),
                BlocProvider<PostBloc>.value(value: mockPostBloc),
              ],
              child: ProfileScreen(uid: state.pathParameters['uid']!),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      // Verify we're on search screen with result
      expect(find.text('Alice'), findsOneWidget,
          reason: 'Search result should be visible');

      // Tap the search result to navigate to profile
      await tester.tap(find.text('Alice'));
      // Pump with explicit duration for navigation animation
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify ProfileScreen is now visible
      expect(find.byType(ProfileScreen), findsOneWidget,
          reason:
              'ProfileScreen should be displayed after tapping search result');

      // Verify back button appears (BackButton widget)
      expect(find.byType(BackButton), findsOneWidget,
          reason:
              'Back button should appear when navigated via context.push()');
    });

    testWidgets(
        'no back button when ProfileScreen is a root route (regression)',
        (WidgetTester tester) async {
      // Build test app where profile is the initial/root location
      // This simulates navigation via context.go (route replacement)
      final router = GoRouter(
        initialLocation: '/profile/$otherUid',
        routes: [
          GoRoute(
            path: '/profile/:uid',
            builder: (ctx, state) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                BlocProvider<UserPostsBloc>.value(value: mockUserPostsBloc),
                BlocProvider<FollowListBloc>.value(value: mockFollowListBloc),
                BlocProvider<PostBloc>.value(value: mockPostBloc),
              ],
              child: ProfileScreen(uid: state.pathParameters['uid']!),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      // Verify ProfileScreen is displayed
      expect(find.byType(ProfileScreen), findsOneWidget,
          reason: 'ProfileScreen should be displayed');

      // Verify NO back button appears (this is a root route)
      expect(find.byType(BackButton), findsNothing,
          reason:
              'Back button should NOT appear when ProfileScreen is a root route');
    });
  });
}
