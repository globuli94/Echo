// lib/features/chat/bloc/chat/chat_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chat_repository.dart';
import '../../data/models/message_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository chatRepository,
    required String currentUserId,
  })  : _chatRepository = chatRepository,
        _currentUserId = currentUserId,
        super(const ChatInitial()) {
    on<ChatSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMarkedAsRead>(_onMarkedAsRead);
  }

  final ChatRepository _chatRepository;
  final String _currentUserId;
  String? _conversationId;

  /// The UID of the authenticated user this bloc was created for.
  String get currentUserId => _currentUserId;

  Future<void> _onSubscriptionRequested(
    ChatSubscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    _conversationId = event.conversationId;
    emit(const ChatLoading());
    await emit.forEach<List<MessageModel>>(
      _chatRepository.watchMessages(event.conversationId),
      onData: ChatLoaded.new,
      onError: (_, __) => const ChatError('Failed to load messages'),
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    try {
      await _chatRepository.sendMessage(
        conversationId,
        _currentUserId,
        event.content,
      );
    } catch (_) {
      // Message list stream will surface any persistent errors.
    }
  }

  Future<void> _onMarkedAsRead(
    ChatMarkedAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.markAsRead(event.conversationId, _currentUserId);
    } catch (_) {
      // Silent — failing to mark as read is non-critical.
    }
  }
}
