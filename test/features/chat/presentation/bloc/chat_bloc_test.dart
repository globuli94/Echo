// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/chat/data/models/message_model.dart';
import 'package:echo/features/chat/data/chat_repository.dart';
import 'package:echo/features/chat/bloc/chat/chat_bloc.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('ChatBloc', () {
    late MockChatRepository mockChatRepository;
    late ChatBloc chatBloc;

    const String conversationId = 'uid-aaa_uid-bbb';
    const String currentUserId = 'uid-aaa';

    setUp(() {
      mockChatRepository = MockChatRepository();
      chatBloc = ChatBloc(
        chatRepository: mockChatRepository,
        currentUserId: currentUserId,
      );
    });

    tearDown(() {
      chatBloc.close();
    });

    group('ChatSubscriptionRequested', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatLoaded] when subscription succeeds',
        build: () {
          final messages = [
            MessageModel(
              messageId: 'msg-1',
              senderId: currentUserId,
              content: 'Hello',
              createdAt: DateTime.now(),
            ),
          ];

          when(() => mockChatRepository.watchMessages(conversationId))
              .thenAnswer((_) => Stream.value(messages));

          return chatBloc;
        },
        act: (bloc) => bloc.add(ChatSubscriptionRequested(conversationId)),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatLoaded>()
              .having((state) => state.messages.length, 'length', 1),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatError] when repository throws',
        build: () {
          when(() => mockChatRepository.watchMessages(conversationId))
              .thenAnswer((_) => Stream.error(Exception('Stream error')));

          return chatBloc;
        },
        act: (bloc) => bloc.add(ChatSubscriptionRequested(conversationId)),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatError>(),
        ],
      );
    });

    group('ChatMessageSent', () {
      test('calls ChatRepository.sendMessage when event is added', () async {
        final messages = [
          MessageModel(
            messageId: 'msg-1',
            senderId: currentUserId,
            content: 'Hello',
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockChatRepository.watchMessages(conversationId))
            .thenAnswer((_) => Stream.value(messages));
        when(() => mockChatRepository.sendMessage(
              conversationId,
              currentUserId,
              'Test message',
            )).thenAnswer((_) async {});

        chatBloc.add(ChatSubscriptionRequested(conversationId));
        await Future.delayed(const Duration(milliseconds: 100));

        chatBloc.add(const ChatMessageSent('Test message'));
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockChatRepository.sendMessage(
              conversationId,
              currentUserId,
              'Test message',
            )).called(1);
      });
    });

    group('ChatMarkedAsRead', () {
      blocTest<ChatBloc, ChatState>(
        'calls ChatRepository.markAsRead with correct parameters',
        build: () {
          when(() => mockChatRepository.markAsRead(
                conversationId,
                currentUserId,
              )).thenAnswer((_) async {});

          return chatBloc;
        },
        act: (bloc) => bloc.add(ChatMarkedAsRead(conversationId)),
        verify: (bloc) {
          verify(() => mockChatRepository.markAsRead(
                conversationId,
                currentUserId,
              )).called(1);
        },
      );
    });
  });
}
