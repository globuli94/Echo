// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/chat/data/models/conversation_model.dart';
import 'package:echo/features/chat/data/chat_repository.dart';
import 'package:echo/features/chat/bloc/conversations/conversations_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('ConversationsBloc', () {
    late MockChatRepository mockChatRepository;
    late ConversationsBloc conversationsBloc;

    setUp(() {
      mockChatRepository = MockChatRepository();
      conversationsBloc = ConversationsBloc(chatRepository: mockChatRepository);
    });

    tearDown(() {
      conversationsBloc.close();
    });

    group('ConversationsSubscriptionRequested', () {
      const String currentUid = 'uid-aaa';

      blocTest<ConversationsBloc, ConversationsState>(
        'emits [ConversationsLoading, ConversationsLoaded] when subscription succeeds',
        build: () {
          final conversations = [
            ConversationModel(
              conversationId: 'uid-aaa_uid-bbb',
              participantIds: ['uid-aaa', 'uid-bbb'],
              lastMessage: 'Hello',
              lastMessageAt: DateTime.now(),
              lastMessageSenderId: 'uid-aaa',
              unreadCounts: {'uid-aaa': 0, 'uid-bbb': 1},
              createdAt: DateTime.now(),
            ),
          ];

          when(() => mockChatRepository.watchConversations(currentUid))
              .thenAnswer((_) => Stream.value(conversations));

          return conversationsBloc;
        },
        act: (bloc) => bloc.add(const ConversationsSubscriptionRequested(uid: currentUid)),
        expect: () => [
          isA<ConversationsLoading>(),
          isA<ConversationsLoaded>()
              .having((state) => state.conversations.length, 'length', 1),
        ],
      );

      blocTest<ConversationsBloc, ConversationsState>(
        'emits [ConversationsLoading, ConversationsError] when repository throws',
        build: () {
          when(() => mockChatRepository.watchConversations(currentUid))
              .thenAnswer((_) => Stream.error(Exception('Stream error')));

          return conversationsBloc;
        },
        act: (bloc) => bloc.add(const ConversationsSubscriptionRequested(uid: currentUid)),
        expect: () => [
          isA<ConversationsLoading>(),
          isA<ConversationsError>(),
        ],
      );

      blocTest<ConversationsBloc, ConversationsState>(
        'emits [ConversationsLoading, ConversationsLoaded] with empty list when no conversations',
        build: () {
          when(() => mockChatRepository.watchConversations(currentUid))
              .thenAnswer((_) => Stream.value([]));

          return conversationsBloc;
        },
        act: (bloc) => bloc.add(const ConversationsSubscriptionRequested(uid: currentUid)),
        expect: () => [
          isA<ConversationsLoading>(),
          isA<ConversationsLoaded>()
              .having((state) => state.conversations.length, 'length', 0),
        ],
      );
    });
  });
}
