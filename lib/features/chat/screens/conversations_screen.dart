// lib/features/chat/screens/conversations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../bloc/conversations/conversations_bloc.dart';
import '../widgets/conversation_tile.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ConversationsBloc>().add(
            ConversationsSubscriptionRequested(uid: authState.user.uid),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsInitial || state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsError) {
            return Center(child: Text(state.message));
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }

            final authState = context.read<AuthBloc>().state;
            final currentUid = authState is AuthAuthenticated
                ? authState.user.uid
                : '';

            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final otherUid = conversation.participantIds
                    .firstWhere((id) => id != currentUid);
                return ConversationTile(
                  conversation: conversation,
                  currentUid: currentUid,
                  onTap: () => context.push(
                    '/chat/${conversation.conversationId}',
                    extra: otherUid,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
