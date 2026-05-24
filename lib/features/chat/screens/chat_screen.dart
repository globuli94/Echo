// lib/features/chat/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.currentUserId,
  });

  final String conversationId;
  final String otherUserId;

  /// The UID of the currently authenticated user. Provided by the router so
  /// this screen has no implicit dependency on [AuthBloc].
  final String currentUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ChatBloc>()
        .add(ChatSubscriptionRequested(widget.conversationId));
    context
        .read<ChatBloc>()
        .add(ChatMarkedAsRead(widget.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = widget.currentUserId;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserId)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatInitial || state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }

                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[
                          state.messages.length - 1 - index];
                      return MessageBubble(
                        message: message,
                        isCurrentUser: message.senderId == currentUid,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          MessageInput(
            onSend: (content) =>
                context.read<ChatBloc>().add(ChatMessageSent(content)),
          ),
        ],
      ),
    );
  }
}
