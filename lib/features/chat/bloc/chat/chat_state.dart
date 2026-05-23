// lib/features/chat/bloc/chat/chat_state.dart

part of 'chat_bloc.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded(this.messages);

  final List<MessageModel> messages;
}

class ChatError extends ChatState {
  const ChatError(this.message);

  final String message;
}
