// lib/features/notifications/presentation/widgets/notification_tile.dart
//
// NotificationTile — renders a single notification item in the list.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
  });

  final AppNotification notification;

  String _actionText() {
    switch (notification.type) {
      case 'like':
        return 'liked your post';
      case 'follow':
        return 'started following you';
      default:
        return 'interacted with you';
    }
  }

  String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = notification.actorAvatarUrl;
    final initial = notification.actorDisplayName.isNotEmpty
        ? notification.actorDisplayName[0].toUpperCase()
        : '?';

    final authState = context.read<AuthBloc?>()?.state;
    final currentUid =
        authState is AuthAuthenticated ? authState.user.uid : '';

    return ListTile(
      tileColor: notification.read
          ? null
          : Theme.of(context).colorScheme.primary.withAlpha(20),
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null
            ? CachedNetworkImageProvider(avatarUrl)
            : null,
        child: avatarUrl == null ? Text(initial) : null,
      ),
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: notification.actorDisplayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${_actionText()}'),
          ],
        ),
      ),
      subtitle: Text(
        _relativeTime(notification.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        if (!notification.read && currentUid.isNotEmpty) {
          context.read<NotificationBloc>().add(
                NotificationReadRequested(
                  uid: currentUid,
                  notificationId: notification.notificationId,
                ),
              );
        }
      },
    );
  }
}
