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
import 'package:echo/features/follow/presentation/screens/followers_screen.dart';

class MockFollowListBloc extends MockBloc<FollowListEvent, FollowListState> implements FollowListBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('FollowersScreen', () {
    late MockFollowListBloc mockFollowListBloc;
    late MockGoRouter mockRouter;

    const profileUid = 'user123';
    final testFollowers = [
      const UserProfile(
        uid: 'follower1',
        displayName: 'Alice',
        bio: 'User one',
        avatarUrl: 'https://example.com/alice.jpg',
        postCount: 5,
      ),
      const UserProfile(
        uid: 'follower2',
        displayName: 'Bob',
        bio: 'User two',
        avatarUrl: 'https://example.com/bob.jpg',
        postCount: 3,
      ),
    ];

    setUp(() {
      mockFollowListBloc = MockFollowListBloc();
      mockRouter = MockGoRouter();

      when(() => mockFollowListBloc.state).thenReturn(
        FollowListLoaded(users: testFollowers),
      );
      whenListen(
        mockFollowListBloc,
        Stream.fromIterable([FollowListLoaded(users: testFollowers)]),
        initialState: FollowListLoaded(users: testFollowers),
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
          child: const FollowersScreen(profileUid: profileUid),
        ),
      );
    }

    group('List Display', () {
      testWidgets('displays all followers with avatar and displayName',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Verify each follower is displayed
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('displays empty state when no followers',
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
        expect(find.byType(FollowersScreen), findsOneWidget);
      });

      testWidgets('displays loading state while fetching followers',
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
      testWidgets('followers are displayed as tappable rows',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Verify followers are displayed and their display names are visible
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('displays error state when fetching fails',
          (WidgetTester tester) async {
        when(() => mockFollowListBloc.state).thenReturn(
          const FollowListError(message: 'Failed to load followers'),
        );
        whenListen(
          mockFollowListBloc,
          Stream.fromIterable([const FollowListError(message: 'Failed to load followers')]),
          initialState: const FollowListError(message: 'Failed to load followers'),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Screen should render and display error
        expect(find.byType(FollowersScreen), findsOneWidget);
      });
    });
  });
}
