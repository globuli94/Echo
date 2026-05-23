// SPDX-License-Identifier: MIT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:echo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:echo/features/auth/domain/entities/auth_user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';
}

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthRemoteDataSource mockAuthRemoteDataSource;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      mockAuthRemoteDataSource = MockAuthRemoteDataSource();

      authRepository = AuthRepositoryImpl(
        dataSource: mockAuthRemoteDataSource,
      );
    });

    group('signInWithEmailAndPassword', () {
      test('should return AuthUser on successful sign in with email and password',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockAuthRemoteDataSource.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<AuthUser>());
        expect(result.uid, equals('test-uid'));
        expect(result.email, equals('test@example.com'));
        verify(() => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should throw exception on sign in failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(() => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(Exception('Sign in failed'));

        // Act & Assert
        expect(
          () => authRepository.signInWithEmailAndPassword(email: email, password: password),
          throwsException,
        );
      });
    });

    group('signUpWithEmailAndPassword', () {
      test(
          'should create user and user document on successful sign up with email and password',
          () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockAuthRemoteDataSource.signUpWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);

        when(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<AuthUser>());
        expect(result.uid, equals('test-uid'));
        verify(() => mockAuthRemoteDataSource.signUpWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
        verify(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).called(1);
      });

      test('should throw exception on sign up failure', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';

        when(() => mockAuthRemoteDataSource.signUpWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(Exception('Sign up failed'));

        // Act & Assert
        expect(
          () => authRepository.signUpWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsException,
        );
      });
    });

    group('signInWithGoogle', () {
      test('should return AuthUser on successful Google sign in', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockAuthRemoteDataSource.signInWithGoogle())
            .thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);

        when(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).thenAnswer((_) async {});

        when(() => mockAuthRemoteDataSource.ensureUserDocument(
          uid: any(named: 'uid'),
          defaultData: any(named: 'defaultData'),
        )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signInWithGoogle();

        // Assert
        expect(result, isA<AuthUser>());
        expect(result.uid, equals('test-uid'));
        verify(() => mockAuthRemoteDataSource.signInWithGoogle()).called(1);
      });

      test('should throw exception on Google sign in failure', () async {
        // Arrange
        when(() => mockAuthRemoteDataSource.signInWithGoogle())
            .thenThrow(Exception('Google sign in failed'));

        // Act & Assert
        expect(
          () => authRepository.signInWithGoogle(),
          throwsException,
        );
      });
    });

    group('signOut', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(() => mockAuthRemoteDataSource.signOut()).thenAnswer((_) async {});

        // Act
        await authRepository.signOut();

        // Assert
        verify(() => mockAuthRemoteDataSource.signOut()).called(1);
      });

      test('should throw exception on sign out failure', () async {
        // Arrange
        when(() => mockAuthRemoteDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act & Assert
        expect(
          () => authRepository.signOut(),
          throwsException,
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';
        when(() => mockAuthRemoteDataSource.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        // Act
        await authRepository.sendPasswordResetEmail(email: email);

        // Assert
        verify(() => mockAuthRemoteDataSource.sendPasswordResetEmail(email: email))
            .called(1);
      });

      test('should throw exception on password reset email failure', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        when(() => mockAuthRemoteDataSource.sendPasswordResetEmail(email: email))
            .thenThrow(Exception('Email not found'));

        // Act & Assert
        expect(
          () => authRepository.sendPasswordResetEmail(email: email),
          throwsException,
        );
      });
    });

    group('createUserDocument', () {
      test('should create user document in Firestore', () async {
        // Arrange
        final user = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).thenAnswer((_) async {});

        // Act
        await authRepository.createUserDocument(user: user);

        // Assert
        verify(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).called(1);
      });

      test('should throw exception on user document creation failure',
          () async {
        // Arrange
        final user = AuthUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(() => mockAuthRemoteDataSource.createUserDocument(
          uid: 'test-uid',
          data: any(named: 'data'),
        )).thenThrow(Exception('Failed to create user document'));

        // Act & Assert
        expect(
          () => authRepository.createUserDocument(user: user),
          throwsException,
        );
      });
    });
  });
}
