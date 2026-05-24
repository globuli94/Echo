// SPDX-License-Identifier: MIT
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo/features/chat/data/chat_repository.dart';

void main() {
  group('ChatRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ChatRepository chatRepository;

    const String uid1 = 'uid-aaa';
    const String uid2 = 'uid-bbb';
    final String conversationId = 'uid-aaa_uid-bbb';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      chatRepository = ChatRepository(firestore: fakeFirestore);
    });

    group('getOrCreateConversation', () {
      test('returns deterministic ID (sorted UIDs joined by underscore)',
          () async {
        final result =
            await chatRepository.getOrCreateConversation(uid1, uid2);
        expect(result, equals(conversationId));
      });

      test('returns same ID regardless of parameter order', () async {
        final result1 =
            await chatRepository.getOrCreateConversation(uid1, uid2);
        final result2 =
            await chatRepository.getOrCreateConversation(uid2, uid1);
        expect(result1, equals(result2));
      });

      test('creates conversation doc on first call', () async {
        await chatRepository.getOrCreateConversation(uid1, uid2);

        final snap = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        expect(snap.exists, isTrue);
        expect(snap['participantIds'], containsAll([uid1, uid2]));
        expect(snap['unreadCounts'], equals({uid1: 0, uid2: 0}));
      });

      test('does not overwrite existing conversation on repeat call', () async {
        await chatRepository.getOrCreateConversation(uid1, uid2);

        // Write a sentinel value to detect overwrites
        await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .update({'lastMessage': 'sentinel'});

        await chatRepository.getOrCreateConversation(uid1, uid2);

        final snap = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        expect(snap['lastMessage'], equals('sentinel'));
      });

      test('returns existing ID on repeat call', () async {
        final result1 =
            await chatRepository.getOrCreateConversation(uid1, uid2);
        final result2 =
            await chatRepository.getOrCreateConversation(uid1, uid2);

        expect(result1, equals(result2));
        expect(result1, equals(conversationId));
      });
    });

    group('sendMessage', () {
      setUp(() async {
        await chatRepository.getOrCreateConversation(uid1, uid2);
      });

      test('writes message document to messages subcollection', () async {
        await chatRepository.sendMessage(conversationId, uid1, 'Hello!');

        final messages = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messages.docs.length, equals(1));
        expect(messages.docs.first['content'], equals('Hello!'));
        expect(messages.docs.first['senderId'], equals(uid1));
      });

      test('updates lastMessage and lastMessageSenderId on conversation',
          () async {
        await chatRepository.sendMessage(conversationId, uid1, 'Hello!');

        final snap = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        expect(snap['lastMessage'], equals('Hello!'));
        expect(snap['lastMessageSenderId'], equals(uid1));
      });

      test('increments unreadCounts for the other participant', () async {
        await chatRepository.sendMessage(conversationId, uid1, 'Hello!');

        final snap = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();

        final unreadCounts =
            Map<String, dynamic>.from(snap['unreadCounts'] as Map);
        expect(unreadCounts[uid2], equals(1)); // recipient incremented
        expect(unreadCounts[uid1], equals(0)); // sender unchanged
      });
    });

    group('markAsRead', () {
      setUp(() async {
        await chatRepository.getOrCreateConversation(uid1, uid2);
        await chatRepository.sendMessage(conversationId, uid1, 'Hello!');
      });

      test('sets unreadCounts for uid to 0', () async {
        // uid2 should have unread count of 1 after receiving a message
        final before = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        expect(
          Map<String, dynamic>.from(before['unreadCounts'] as Map)[uid2],
          equals(1),
        );

        await chatRepository.markAsRead(conversationId, uid2);

        final after = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        expect(
          Map<String, dynamic>.from(after['unreadCounts'] as Map)[uid2],
          equals(0),
        );
      });
    });

    group('watchConversations', () {
      test('emits empty list when no conversations exist', () async {
        final stream = chatRepository.watchConversations(uid1);
        final result = await stream.first;
        expect(result, isEmpty);
      });

      test('emits conversation after it is created', () async {
        await chatRepository.getOrCreateConversation(uid1, uid2);

        // Add lastMessageAt so the orderBy query works
        await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .update({'lastMessageAt': DateTime.now()});

        final stream = chatRepository.watchConversations(uid1);
        final result = await stream.first;

        expect(result.length, equals(1));
        expect(result.first.conversationId, equals(conversationId));
      });
    });

    group('watchMessages', () {
      setUp(() async {
        await chatRepository.getOrCreateConversation(uid1, uid2);
      });

      test('emits empty list when no messages exist', () async {
        final stream = chatRepository.watchMessages(conversationId);
        final result = await stream.first;
        expect(result, isEmpty);
      });

      test('emits messages after they are sent', () async {
        await chatRepository.sendMessage(conversationId, uid1, 'Hello!');

        final stream = chatRepository.watchMessages(conversationId);
        final result = await stream.first;

        expect(result.length, equals(1));
        expect(result.first.content, equals('Hello!'));
        expect(result.first.senderId, equals(uid1));
      });
    });
  });
}
