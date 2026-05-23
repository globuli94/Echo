// Copyright (c) 2024. All rights reserved.
// Test suite for UserSearchResultCard widget.

import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/follow/domain/entities/follow_status.dart';
import 'package:echo/features/follow/presentation/bloc/follow_bloc.dart';
import 'package:echo/features/follow/presentation/bloc/follow_state.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/search/presentation/widgets/user_search_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFollowBloc extends MockBloc<dynamic, dynamic> implements FollowBloc {}

void main() {
  late MockFollowBloc mockFollowBloc;

  setUp(() {
    mockFollowBloc = MockFollowBloc();
  });

  Widget createWidgetUnderTest({
    required UserProfile user,
    required String currentUid,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<FollowBloc>.value(
          value: mockFollowBloc,
          child: UserSearchResultCard(
            user: user,
            currentUid: currentUid,
            onTap: onTap,
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
      when(() => mockFollowBloc.state).thenReturn(
        FollowStatusLoaded(
          status: FollowStatus(isFollowing: false, targetUid: 'uid1'),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
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
      when(() => mockFollowBloc.state).thenReturn(
        FollowStatusLoaded(
          status: FollowStatus(isFollowing: false, targetUid: 'uid1'),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
        ),
      );

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
      when(() => mockFollowBloc.state).thenReturn(
        FollowStatusLoaded(
          status: FollowStatus(isFollowing: true, targetUid: 'uid1'),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () {},
        ),
      );

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
      when(() => mockFollowBloc.state).thenReturn(
        FollowStatusLoaded(
          status: FollowStatus(isFollowing: false, targetUid: 'sameUid'),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'sameUid',
          onTap: () {},
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
      when(() => mockFollowBloc.state).thenReturn(
        FollowStatusLoaded(
          status: FollowStatus(isFollowing: false, targetUid: 'uid1'),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          user: user,
          currentUid: 'currentUser',
          onTap: () => tapCount++,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });
  });
}
