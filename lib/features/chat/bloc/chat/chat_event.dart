// lib/features/chat/bloc/chat/chat_event.dart

part of 'chat_bloc.dart';

abstract class ChatEvent {
  const ChatEvent();
}

/// Starts the real-time messages stream for [conversationId].
class ChatSubscriptionRequested extends ChatEvent {
  const ChatSubscriptionRequested(this.conversationId);

  final String conversationId;
}

/// Sends a new message with [content].
class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.content);

  final String content;
}

/// Marks the conversation as read for the current user.
class ChatMarkedAsRead extends ChatEvent {
  const ChatMarkedAsRead(this.conversationId);

  final String conversationId;
}
