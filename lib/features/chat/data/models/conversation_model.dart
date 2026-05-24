// lib/features/chat/data/models/conversation_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  const ConversationModel({
    required this.conversationId,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCounts,
    required this.createdAt,
  });

  final String conversationId;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;

  factory ConversationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      conversationId: doc.id,
      participantIds: List<String>.from(data['participantIds'] as List),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      unreadCounts: Map<String, int>.from(
        (data['unreadCounts'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
