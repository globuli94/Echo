// lib/features/chat/bloc/conversations/conversations_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chat_repository.dart';
import '../../data/models/conversation_model.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc
    extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ConversationsInitial()) {
    on<ConversationsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final ChatRepository _chatRepository;
  StreamSubscription<List<ConversationModel>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ConversationsSubscriptionRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(const ConversationsLoading());
    await _subscription?.cancel();
    await emit.forEach<List<ConversationModel>>(
      _chatRepository.watchConversations(event.uid),
      onData: ConversationsLoaded.new,
      onError: (_, __) => const ConversationsError('Failed to load conversations'),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
