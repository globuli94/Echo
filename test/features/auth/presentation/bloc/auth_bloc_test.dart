// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';
import 'package:echo/features/auth/domain/repositories/auth_repository.dart';
import 'package:echo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:echo/features/auth/presentation/bloc/auth_event.dart';
import 'package:echo/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(repository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    group('initial state', () {
      test('emits AuthInitial state on initialization', () {
        expect(authBloc.state, isA<AuthInitial>());
      });
    });

    group('SignInWithEmailAndPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful sign in',
        build: () {
          const email = 'test@example.com';
          const password = 'password123';
          final authUser = AuthUser(
            uid: 'test-uid',
            email: email,
            displayName: 'Test User',
          );

          when(() => mockAuthRepository.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => authUser);

          return authBloc;
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.user.uid, 'uid', 'test-uid'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on sign in failure',
        build: () {
          const email = 'test@example.com';
          const password = 'wrongpassword';

          when(() => mockAuthRepository.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(Exception('Invalid credentials'));

          return authBloc;
        },
        act: (bloc) => bloc.add(
          SignInWithEmailAndPasswordRequested(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>()
              .having((state) => state.error, 'error', contains('Invalid')),
        ],
      );
    });

    group('SignUpWithEmailAndPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful sign up',
        build: () {
          const email = 'newuser@example.com';
          const password = 'password123';
          final authUser = AuthUser(
            uid: 'new-uid',
            email: email,
            displayName: 'New User',
          );

          when(() => mockAuthRepository.signUpWithEmailAndPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => authUser);

          return authBloc;
        },
        act: (bloc) => bloc.add(
          SignUpWithEmailAndPasswordRequested(
            email: 'newuser@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.user.uid, 'uid', 'new-uid'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on sign up failure',
        build: () {
          const email = 'test@example.com';
          const password = 'password123';

          when(() => mockAuthRepository.signUpWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(Exception('Email already in use'));

          return authBloc;
        },
        act: (bloc) => bloc.add(
          SignUpWithEmailAndPasswordRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>()
              .having((state) => state.error, 'error',
                  contains('Email already in use')),
        ],
      );
    });

    group('SignInWithGoogleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful Google sign in',
        build: () {
          final authUser = AuthUser(
            uid: 'google-uid',
            email: 'user@gmail.com',
            displayName: 'Google User',
          );

          when(() => mockAuthRepository.signInWithGoogle())
              .thenAnswer((_) async => authUser);

          return authBloc;
        },
        act: (bloc) => bloc.add(SignInWithGoogleRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.user.uid, 'uid', 'google-uid'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on Google sign in failure',
        build: () {
          when(() => mockAuthRepository.signInWithGoogle())
              .thenThrow(Exception('Google sign in failed'));

          return authBloc;
        },
        act: (bloc) => bloc.add(SignInWithGoogleRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>()
              .having((state) => state.error, 'error',
                  contains('Google sign in failed')),
        ],
      );
    });

    group('ForgotPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, ForgotPasswordEmailSent] on successful password reset',
        build: () {
          const email = 'test@example.com';

          when(() => mockAuthRepository.sendPasswordResetEmail(email: email))
              .thenAnswer((_) async {});

          return authBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordRequested(email: 'test@example.com')),
        expect: () => [
          isA<AuthLoading>(),
          isA<ForgotPasswordEmailSent>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on password reset email failure',
        build: () {
          const email = 'nonexistent@example.com';

          when(() => mockAuthRepository.sendPasswordResetEmail(email: email))
              .thenThrow(Exception('Email not found'));

          return authBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordRequested(email: 'nonexistent@example.com')),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>()
              .having((state) => state.error, 'error',
                  contains('Email not found')),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should call signOut on repository',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async {});

          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        verify: (bloc) {
          verify(() => mockAuthRepository.signOut()).called(1);
        },
      );
    });
  });
}
