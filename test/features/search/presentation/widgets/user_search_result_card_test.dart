// Copyright (c) 2024. All rights reserved.
// Test suite for UserSearchResultCard widget.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';
import 'package:echo/features/follow/domain/entities/follow_status.dart';
import 'package:echo/features/follow/domain/repositories/follow_repository.dart';
import 'package:echo/features/follow/presentation/bloc/follow_bloc.dart';
import 'package:echo/features/follow/presentation/bloc/follow_event.dart';
import 'package:echo/features/follow/presentation/bloc/follow_state.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/search/presentation/widgets/user_search_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFollowRepository extends Mock implements FollowRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockFollowRepository mockFollowRepository;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockFollowRepository = MockFollowRepository();
    mockAuthBloc = MockAuthBloc();
    // Mock AuthBloc state to be AuthUnauthenticated (fallback to currentUid)
    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
  });

  Widget createWidgetUnderTest({
    required UserProfile user,
    required String currentUid,
    required VoidCallback onTap,
    required FollowStatus followStatus,
  }) {
    // Create a broadcast stream that emits the follow status
    // Use asBroadcastStream() on Future.value to create a reusable stream
    final stream = Stream.value(followStatus).asBroadcastStream();

    // Mock the repository to return the stream - use specific values to avoid matcher issues
    when(() => mockFollowRepository.streamFollowStatus(
          currentUid: currentUid,
          targetUid: user.uid,
        )).thenAnswer((_) => stream);

    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 800,
            height: 200,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                RepositoryProvider<FollowRepository>.value(
                  value: mockFollowRepository,
                ),
              ],
              child: UserSearchResultCard(
                user: user,
                currentUid: currentUid,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('UserSearchResultCard', () {
    testWidgets('renders displayName', (WidgetTester tester) async {
      final user = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      final followStatus =
          FollowStatus(isFollowing: false, targetUid: 'uid1');

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
          followStatus: followStatus,
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows Follow button when not following',
        (WidgetTester tester) async {
      final user = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      final followStatus =
          FollowStatus(isFollowing: false, targetUid: 'uid1');

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
          followStatus: followStatus,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('shows Unfollow button when following',
        (WidgetTester tester) async {
      final user = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      final followStatus = FollowStatus(isFollowing: true, targetUid: 'uid1');

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
          followStatus: followStatus,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Unfollow'), findsOneWidget);
    });

    testWidgets('hides follow button for own uid', (WidgetTester tester) async {
      final user = UserProfile(
        uid: 'sameUid',
        displayName: 'Me',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      final followStatus =
          FollowStatus(isFollowing: false, targetUid: 'sameUid');

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'sameUid',
          onTap: () {},
          followStatus: followStatus,
        ),
      );

      expect(find.text('Follow'), findsNothing);
      expect(find.text('Unfollow'), findsNothing);
    });

    testWidgets('calls onTap when card tapped', (WidgetTester tester) async {
      var tapCount = 0;
      final user = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      final followStatus =
          FollowStatus(isFollowing: false, targetUid: 'uid1');

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () => tapCount++,
          followStatus: followStatus,
        ),
      );

      // Tap the card's InkWell (not the button's)
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });
  });
}
