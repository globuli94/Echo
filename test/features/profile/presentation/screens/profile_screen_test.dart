// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:echo/features/profile/presentation/bloc/profile_event.dart';
import 'package:echo/features/profile/presentation/bloc/profile_state.dart';
import 'package:echo/features/profile/presentation/screens/profile_screen.dart';
import 'package:echo/features/posts/domain/entities/post.dart';
import 'package:echo/features/posts/domain/entities/post_with_author.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_bloc.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_event.dart';
import 'package:echo/features/posts/presentation/bloc/user_posts_state.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockUserPostsBloc extends MockBloc<UserPostsEvent, UserPostsState> implements UserPostsBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('ProfileScreen', () {
    late MockProfileBloc mockProfileBloc;
    late MockUserPostsBloc mockUserPostsBloc;
    late MockAuthBloc mockAuthBloc;

    const testUid = 'user123';
    const testProfile = UserProfile(
      uid: testUid,
      displayName: 'John Doe',
      bio: 'Flutter developer',
      avatarUrl: 'https://example.com/avatar.jpg',
      postCount: 2,
    );

    final testPosts = [
      PostWithAuthor(
        post: Post(
          postId: 'post1',
          authorId: testUid,
          content: 'First post',
          imageUrl: null,
          likeCount: 0,
          commentCount: 0,
          createdAt: DateTime(2026, 5, 23),
        ),
        authorDisplayName: 'John Doe',
        authorAvatarUrl: 'https://example.com/avatar.jpg',
      ),
      PostWithAuthor(
        post: Post(
          postId: 'post2',
          authorId: testUid,
          content: 'Second post',
          imageUrl: null,
          likeCount: 1,
          commentCount: 0,
          createdAt: DateTime(2026, 5, 22),
        ),
        authorDisplayName: 'John Doe',
        authorAvatarUrl: 'https://example.com/avatar.jpg',
      ),
    ];

    setUp(() {
      mockProfileBloc = MockProfileBloc();
      mockUserPostsBloc = MockUserPostsBloc();
      mockAuthBloc = MockAuthBloc();

      final authUser = const AuthUser(
        uid: testUid,
        email: 'test@example.com',
        displayName: 'John Doe',
      );

      // Default mock states
      when(() => mockProfileBloc.state).thenReturn(
        const ProfileLoaded(profile: testProfile, isOwner: true),
      );
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([const ProfileLoaded(profile: testProfile, isOwner: true)]),
        initialState: const ProfileLoaded(profile: testProfile, isOwner: true),
      );

      when(() => mockUserPostsBloc.state).thenReturn(
        UserPostsLoaded(posts: testPosts),
      );
      whenListen(
        mockUserPostsBloc,
        Stream.fromIterable([UserPostsLoaded(posts: testPosts)]),
        initialState: UserPostsLoaded(posts: testPosts),
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: authUser),
      );
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthAuthenticated(user: authUser)]),
        initialState: AuthAuthenticated(user: authUser),
      );
    });

    Widget createWidgetUnderTest({String? uid}) {
      return MaterialApp.router(
        routerConfig: GoRouter(
          routes: [],
          redirect: (_, __) => null,
        ),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
            BlocProvider<UserPostsBloc>.value(value: mockUserPostsBloc),
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          ],
          child: ProfileScreen(uid: uid),
        ),
      );
    }

    testWidgets('ProfileScreen displays posts when user has posts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // AC: ProfileScreen shows a scrollable list/grid of posts authored by the viewed user, sorted newest-first
      expect(find.text('First post'), findsOneWidget);
      expect(find.text('Second post'), findsOneWidget);
    });
  });
}
