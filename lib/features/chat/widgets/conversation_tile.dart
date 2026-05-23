// lib/features/chat/widgets/conversation_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUid,
    required this.onTap,
  });

  final ConversationModel conversation;
  final String currentUid;
  final VoidCallback onTap;

  String get _otherUid =>
      conversation.participantIds.firstWhere((id) => id != currentUid);

  int get _unreadCount => conversation.unreadCounts[currentUid] ?? 0;

  @override
  Widget build(BuildContext context) {
    final lastMessageAt = conversation.lastMessageAt;
    final timeLabel = lastMessageAt != null
        ? DateFormat('MMM d · h:mm a').format(lastMessageAt.toLocal())
        : '';

    return ListTile(
      leading: CircleAvatar(
        child: Text(_otherUid[0].toUpperCase()),
      ),
      title: Text(
        _otherUid,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(height: 4),
            Badge.count(count: _unreadCount),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
