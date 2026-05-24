// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/notifications/domain/entities/app_notification.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_event.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_state.dart';
import 'package:echo/features/notifications/presentation/screens/notifications_screen.dart';

class MockNotificationBloc extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

AppNotification makeNotification({
  String notificationId = 'notif-1',
  String type = 'like',
  String actorUid = 'user-1',
  String actorDisplayName = 'Alice',
  String? actorAvatarUrl,
  String? postId,
  bool read = false,
  DateTime? createdAt,
}) =>
    AppNotification(
      notificationId: notificationId,
      type: type,
      actorUid: actorUid,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      postId: postId,
      read: read,
      createdAt: createdAt ?? DateTime(2026, 5, 24),
    );

void main() {
  group('NotificationsScreen', () {
    late MockNotificationBloc mockNotificationBloc;

    setUp(() {
      mockNotificationBloc = MockNotificationBloc();
    });

    Widget buildSubject() => MaterialApp(
          home: BlocProvider<NotificationBloc>.value(
            value: mockNotificationBloc,
            child: const NotificationsScreen(),
          ),
        );

    testWidgets(
        'displays notifications in ListView when NotificationsLoaded with notifications',
        (WidgetTester tester) async {
      // Arrange
      final notifications = [
        makeNotification(notificationId: 'notif-1', actorDisplayName: 'Alice'),
        makeNotification(notificationId: 'notif-2', actorDisplayName: 'Bob'),
      ];

      when(() => mockNotificationBloc.state)
          .thenReturn(NotificationsLoaded(notifications: notifications));
      whenListen(
        mockNotificationBloc,
        Stream.fromIterable([NotificationsLoaded(notifications: notifications)]),
        initialState: NotificationsLoaded(notifications: notifications),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(find.byType(ListView), findsOneWidget,
          reason: 'ListView should be displayed with notifications');
    });

    testWidgets(
        'shows empty state text "No notifications yet" when notifications list is empty',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationBloc.state)
          .thenReturn(const NotificationsLoaded(notifications: []));
      whenListen(
        mockNotificationBloc,
        Stream.fromIterable([const NotificationsLoaded(notifications: [])]),
        initialState: const NotificationsLoaded(notifications: []),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(
        find.text('No notifications yet'),
        findsOneWidget,
        reason: 'Empty state message should be shown when there are no notifications',
      );
    });

    testWidgets('shows loading state with CircularProgressIndicator',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationBloc.state)
          .thenReturn(const NotificationsLoading());
      whenListen(
        mockNotificationBloc,
        Stream.fromIterable([const NotificationsLoading()]),
        initialState: const NotificationsLoading(),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'Loading indicator should be shown when loading notifications');
    });

    testWidgets('shows error message when NotificationsError',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load notifications';
      when(() => mockNotificationBloc.state)
          .thenReturn(const NotificationsError(message: errorMessage));
      whenListen(
        mockNotificationBloc,
        Stream.fromIterable(
            [const NotificationsError(message: errorMessage)]),
        initialState: const NotificationsError(message: errorMessage),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(find.text(errorMessage), findsOneWidget,
          reason: 'Error message should be displayed');
    });

    testWidgets('has app bar with title "Notifications"',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationBloc.state)
          .thenReturn(const NotificationsLoaded(notifications: []));
      whenListen(
        mockNotificationBloc,
        Stream.fromIterable([const NotificationsLoaded(notifications: [])]),
        initialState: const NotificationsLoaded(notifications: []),
      );

      // Act
      await tester.pumpWidget(buildSubject());

      // Assert
      expect(find.text('Notifications'), findsOneWidget,
          reason: 'App bar should have "Notifications" title');
    });
  });
}
