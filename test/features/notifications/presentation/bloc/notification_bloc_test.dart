// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/notifications/domain/repositories/notification_repository.dart';
import 'package:echo/features/notifications/domain/entities/app_notification.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_event.dart';
import 'package:echo/features/notifications/presentation/bloc/notification_state.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

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
  group('NotificationBloc', () {
    late MockNotificationRepository mockNotificationRepository;
    late NotificationBloc notificationBloc;

    setUp(() {
      mockNotificationRepository = MockNotificationRepository();
      notificationBloc = NotificationBloc(
        repository: mockNotificationRepository,
      );
    });

    tearDown(() {
      notificationBloc.close();
    });

    group('NotificationsSubscribed', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationsLoading, NotificationsLoaded] when streamNotifications succeeds',
        setUp: () {
          final notifications = [makeNotification()];
          when(() => mockNotificationRepository.streamNotifications(
                uid: 'test-uid',
              )).thenAnswer((_) => Stream.value(notifications));
        },
        build: () => notificationBloc,
        act: (bloc) => bloc.add(const NotificationsSubscribed(uid: 'test-uid')),
        expect: () => [
          isA<NotificationsLoading>(),
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.length, 'length', 1),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationsLoading, NotificationsLoaded] with empty list when no notifications',
        setUp: () {
          when(() => mockNotificationRepository.streamNotifications(
                uid: 'test-uid',
              )).thenAnswer((_) => Stream.value([]));
        },
        build: () => notificationBloc,
        act: (bloc) => bloc.add(const NotificationsSubscribed(uid: 'test-uid')),
        expect: () => [
          isA<NotificationsLoading>(),
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.length, 'length', 0),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationsError when subscription fails',
        setUp: () {
          when(() => mockNotificationRepository.streamNotifications(
                uid: 'test-uid',
              )).thenAnswer((_) => Stream.error(Exception('Stream error')));
        },
        build: () => notificationBloc,
        act: (bloc) => bloc.add(const NotificationsSubscribed(uid: 'test-uid')),
        expect: () => [
          isA<NotificationsLoading>(),
          isA<NotificationsError>(),
        ],
      );
    });

    group('NotificationReadRequested', () {
      blocTest<NotificationBloc, NotificationState>(
        'calls repository.markAsRead when NotificationReadRequested is added',
        setUp: () {
          when(() => mockNotificationRepository.markAsRead(
            uid: 'test-uid',
            notificationId: 'notif-1',
          )).thenAnswer((_) async {});

          when(() => mockNotificationRepository.streamNotifications(
                uid: 'test-uid',
              )).thenAnswer((_) => Stream.value([]));
        },
        build: () => notificationBloc,
        act: (bloc) async {
          bloc.add(const NotificationsSubscribed(uid: 'test-uid'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const NotificationReadRequested(
            uid: 'test-uid',
            notificationId: 'notif-1',
          ));
        },
        verify: (bloc) {
          verify(() => mockNotificationRepository.markAsRead(
            uid: 'test-uid',
            notificationId: 'notif-1',
          )).called(1);
        },
      );
    });
  });
}
