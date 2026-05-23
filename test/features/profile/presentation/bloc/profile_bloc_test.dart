import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:echo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:echo/features/profile/presentation/bloc/profile_event.dart';
import 'package:echo/features/profile/presentation/bloc/profile_state.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late ProfileBloc profileBloc;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    profileBloc = ProfileBloc(repository: mockRepository);
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc', () {
    group('ProfileLoadRequested', () {
      const testUid = 'user123';
      const testViewerUid = 'user123';
      const testProfile = UserProfile(
        uid: testUid,
        displayName: 'John Doe',
        bio: 'Flutter developer',
        avatarUrl: 'https://example.com/avatar.jpg',
        postCount: 5,
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded(isOwner: true)] when uid == viewerUid',
        setUp: () {
          when(() => mockRepository.getUserProfile(testUid))
              .thenAnswer((_) async => testProfile);
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileLoadRequested(uid: testUid, viewerUid: testViewerUid),
        ),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', testProfile)
              .having((state) => state.isOwner, 'isOwner', true),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded(isOwner: false)] when uid != viewerUid',
        setUp: () {
          const otherUid = 'user456';
          when(() => mockRepository.getUserProfile(otherUid))
              .thenAnswer((_) async => testProfile);
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileLoadRequested(uid: 'user456', viewerUid: testViewerUid),
        ),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', testProfile)
              .having((state) => state.isOwner, 'isOwner', false),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileFailure] when repository throws',
        setUp: () {
          when(() => mockRepository.getUserProfile(testUid))
              .thenThrow(Exception('Failed to load profile'));
        },
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileLoadRequested(uid: testUid, viewerUid: testViewerUid),
        ),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileFailure>(),
        ],
      );
    });

    group('ProfileUpdateRequested', () {
      const testUid = 'user123';
      const newDisplayName = 'Jane Doe';
      const newBio = 'Mobile developer';
      const oldProfile = UserProfile(
        uid: testUid,
        displayName: 'John Doe',
        bio: 'Flutter developer',
        avatarUrl: 'https://example.com/avatar.jpg',
        postCount: 5,
      );
      const updatedProfile = UserProfile(
        uid: testUid,
        displayName: newDisplayName,
        bio: newBio,
        avatarUrl: 'https://example.com/avatar.jpg',
        postCount: 5,
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] with updated displayName and bio on success',
        setUp: () {
          when(() => mockRepository.updateProfile(
            uid: testUid,
            displayName: newDisplayName,
            bio: newBio,
          )).thenAnswer((_) async {});
          when(() => mockRepository.getUserProfile(testUid))
              .thenAnswer((_) async => updatedProfile);
        },
        seed: () => const ProfileLoaded(profile: oldProfile, isOwner: true),
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileUpdateRequested(
            uid: testUid,
            displayName: newDisplayName,
            bio: newBio,
          ),
        ),
        expect: () => [
          const TypeMatcher<ProfileUpdating>(),
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', updatedProfile)
              .having((state) => state.profile.displayName, 'displayName',
                  newDisplayName)
              .having((state) => state.profile.bio, 'bio', newBio),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileFailure] when repository throws',
        setUp: () {
          when(() => mockRepository.updateProfile(
            uid: testUid,
            displayName: newDisplayName,
            bio: newBio,
          )).thenThrow(Exception('Failed to update profile'));
        },
        seed: () => const ProfileLoaded(profile: oldProfile, isOwner: true),
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileUpdateRequested(
            uid: testUid,
            displayName: newDisplayName,
            bio: newBio,
          ),
        ),
        expect: () => [
          const TypeMatcher<ProfileUpdating>(),
          isA<ProfileFailure>(),
        ],
      );
    });

    group('ProfileAvatarUploadRequested', () {
      const testUid = 'user123';
      const imagePath = '/path/to/avatar.jpg';
      const newAvatarUrl = 'https://example.com/new-avatar.jpg';
      const oldProfile = UserProfile(
        uid: testUid,
        displayName: 'John Doe',
        bio: 'Flutter developer',
        avatarUrl: 'https://example.com/avatar.jpg',
        postCount: 5,
      );
      const profileWithNewAvatar = UserProfile(
        uid: testUid,
        displayName: 'John Doe',
        bio: 'Flutter developer',
        avatarUrl: newAvatarUrl,
        postCount: 5,
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] with new avatarUrl on success',
        setUp: () {
          when(() => mockRepository.uploadAvatar(
            uid: testUid,
            imagePath: imagePath,
          )).thenAnswer((_) async => newAvatarUrl);
        },
        seed: () => const ProfileLoaded(profile: oldProfile, isOwner: true),
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileAvatarUploadRequested(uid: testUid, imagePath: imagePath),
        ),
        expect: () => [
          const TypeMatcher<ProfileUpdating>(),
          isA<ProfileLoaded>()
              .having((state) => state.profile, 'profile', profileWithNewAvatar)
              .having(
                  (state) => state.profile.avatarUrl, 'avatarUrl', newAvatarUrl),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileFailure] when repository throws',
        setUp: () {
          when(() => mockRepository.uploadAvatar(
            uid: testUid,
            imagePath: imagePath,
          )).thenThrow(Exception('Failed to upload avatar'));
        },
        seed: () => const ProfileLoaded(profile: oldProfile, isOwner: true),
        build: () => profileBloc,
        act: (bloc) => bloc.add(
          ProfileAvatarUploadRequested(uid: testUid, imagePath: imagePath),
        ),
        expect: () => [
          const TypeMatcher<ProfileUpdating>(),
          isA<ProfileFailure>(),
        ],
      );
    });
  });
}
