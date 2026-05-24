// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final MessageModel message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isCurrentUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isCurrentUser
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final timeLabel =
        DateFormat('h:mm a').format(message.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeLabel,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
