// lib/features/chat/bloc/conversations/conversations_state.dart

part of 'conversations_bloc.dart';

abstract class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded(this.conversations);

  final List<ConversationModel> conversations;
}

class ConversationsError extends ConversationsState {
  const ConversationsError(this.message);

  final String message;
}
