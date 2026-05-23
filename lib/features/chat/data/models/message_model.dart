// lib/features/chat/data/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final String messageId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
