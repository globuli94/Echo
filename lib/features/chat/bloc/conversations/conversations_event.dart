// lib/features/chat/bloc/conversations/conversations_event.dart

part of 'conversations_bloc.dart';

abstract class ConversationsEvent {
  const ConversationsEvent();
}

/// Starts the real-time conversations stream for [uid].
class ConversationsSubscriptionRequested extends ConversationsEvent {
  const ConversationsSubscriptionRequested({required this.uid});

  final String uid;
}
