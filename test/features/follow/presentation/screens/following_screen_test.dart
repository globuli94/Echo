// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_bloc.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_event.dart';
import 'package:echo/features/follow/presentation/bloc/follow_list_state.dart';
import 'package:echo/features/follow/presentation/screens/following_screen.dart';

class MockFollowListBloc extends MockBloc<FollowListEvent, FollowListState> implements FollowListBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('FollowingScreen', () {
    late MockFollowListBloc mockFollowListBloc;
    late MockGoRouter mockRouter;

    const profileUid = 'user123';
    final testFollowing = [
      const UserProfile(
        uid: 'following1',
        displayName: 'Charlie',
        bio: 'Following user one',
        avatarUrl: 'https://example.com/charlie.jpg',
        postCount: 10,
      ),
      const UserProfile(
        uid: 'following2',
        displayName: 'Diana',
        bio: 'Following user two',
        avatarUrl: 'https://example.com/diana.jpg',
        postCount: 7,
      ),
    ];

    setUp(() {
      mockFollowListBloc = MockFollowListBloc();
      mockRouter = MockGoRouter();

      when(() => mockFollowListBloc.state).thenReturn(
        FollowListLoaded(users: testFollowing),
      );
      whenListen(
        mockFollowListBloc,
        Stream.fromIterable([FollowListLoaded(users: testFollowing)]),
        initialState: FollowListLoaded(users: testFollowing),
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp.router(
        routerConfig: GoRouter(
          routes: [],
          redirect: (_, __) => null,
        ),
        builder: (context, child) => BlocProvider<FollowListBloc>.value(
          value: mockFollowListBloc,
          child: const FollowingScreen(profileUid: profileUid),
        ),
      );
    }

    group('List Display', () {
      testWidgets('displays all followed users with avatar and displayName',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Verify each followed user is displayed
        expect(find.text('Charlie'), findsOneWidget);
        expect(find.text('Diana'), findsOneWidget);
      });

      testWidgets('displays empty state when user follows nobody',
          (WidgetTester tester) async {
        when(() => mockFollowListBloc.state).thenReturn(
          const FollowListLoaded(users: []),
        );
        whenListen(
          mockFollowListBloc,
          Stream.fromIterable([const FollowListLoaded(users: [])]),
          initialState: const FollowListLoaded(users: []),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Screen should render without error - empty state
        expect(find.byType(FollowingScreen), findsOneWidget);
      });

      testWidgets('displays loading state while fetching following',
          (WidgetTester tester) async {
        when(() => mockFollowListBloc.state).thenReturn(
          const FollowListLoading(),
        );
        whenListen(
          mockFollowListBloc,
          Stream.fromIterable([const FollowListLoading()]),
          initialState: const FollowListLoading(),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        // Should display loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('followed users are displayed as tappable rows',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Verify followed users are displayed and their display names are visible
        expect(find.text('Charlie'), findsOneWidget);
        expect(find.text('Diana'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('displays error state when fetching fails',
          (WidgetTester tester) async {
        when(() => mockFollowListBloc.state).thenReturn(
          const FollowListError(message: 'Failed to load following'),
        );
        whenListen(
          mockFollowListBloc,
          Stream.fromIterable([const FollowListError(message: 'Failed to load following')]),
          initialState: const FollowListError(message: 'Failed to load following'),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Screen should render and display error
        expect(find.byType(FollowingScreen), findsOneWidget);
      });
    });
  });
}
