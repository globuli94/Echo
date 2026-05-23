// lib/features/chat/data/chat_repository.dart
//
// ChatRepository — all Firestore calls for the chat feature.
// No Firestore code lives outside this class.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/conversation_model.dart';
import 'models/message_model.dart';

class ChatRepository {
  ChatRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  /// Real-time stream of conversations the [uid] participates in,
  /// ordered by [lastMessageAt] descending.
  Stream<List<ConversationModel>> watchConversations(String uid) {
    return _conversations
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ConversationModel.fromDoc).toList());
  }

  /// Real-time stream of messages in a conversation, ordered by [createdAt]
  /// ascending.
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MessageModel.fromDoc).toList());
  }

  /// Sends a message and updates the conversation metadata.
  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    final convRef = _conversations.doc(conversationId);

    await _firestore.runTransaction((tx) async {
      final convSnap = await tx.get(convRef);
      final participantIds =
          List<String>.from(convSnap['participantIds'] as List);
      final otherUid =
          participantIds.firstWhere((id) => id != senderId);

      final msgRef = convRef.collection('messages').doc();
      final now = FieldValue.serverTimestamp();

      tx.set(msgRef, {
        'messageId': msgRef.id,
        'senderId': senderId,
        'content': content,
        'createdAt': now,
      });

      tx.update(convRef, {
        'lastMessage': content,
        'lastMessageAt': now,
        'lastMessageSenderId': senderId,
        'unreadCounts.$otherUid': FieldValue.increment(1),
      });
    });
  }

  /// Returns the conversation ID for the pair [uidA]/[uidB].
  /// Creates the conversation document if it does not yet exist.
  Future<String> getOrCreateConversation(String uidA, String uidB) async {
    final sorted = [uidA, uidB]..sort();
    final conversationId = '${sorted[0]}_${sorted[1]}';
    final ref = _conversations.doc(conversationId);

    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'conversationId': conversationId,
        'participantIds': sorted,
        'lastMessage': null,
        'lastMessageAt': null,
        'lastMessageSenderId': null,
        'unreadCounts': {uidA: 0, uidB: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return conversationId;
  }

  /// Sets the unread count for [uid] in [conversationId] to 0.
  Future<void> markAsRead(String conversationId, String uid) async {
    await _conversations.doc(conversationId).update({
      'unreadCounts.$uid': 0,
    });
  }
}
