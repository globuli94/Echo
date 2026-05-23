// lib/main.dart
//
// Application entry point. Initialises Firebase, wires up repositories and
// BLoCs, and mounts the root widget.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/follow/data/datasources/follow_remote_data_source.dart';
import 'features/follow/data/repositories/follow_repository_impl.dart';
import 'features/follow/domain/repositories/follow_repository.dart';
import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/repositories/post_repository.dart';
import 'features/posts/presentation/bloc/post_bloc.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/user_profile_repository_impl.dart';
import 'features/profile/domain/repositories/user_profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

/// Initialises Firebase and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase already initialised on the native side (e.g. hot restart).
  }

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final dataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: firestore,
  );
  final authRepository = AuthRepositoryImpl(dataSource: dataSource);
  final authBloc = AuthBloc(repository: authRepository)
    ..add(const AuthStarted());

  final profileDataSource = ProfileRemoteDataSourceImpl(
    firestore: firestore,
    storage: storage,
  );
  final userProfileRepository =
      UserProfileRepositoryImpl(dataSource: profileDataSource);

  final postDataSource = PostRemoteDataSourceImpl(
    firestore: firestore,
    storage: storage,
  );
  final postRepository = PostRepositoryImpl(dataSource: postDataSource);

  final followDataSource = FollowRemoteDataSourceImpl(firestore: firestore);
  final followRepository = FollowRepositoryImpl(dataSource: followDataSource);

  final router = createRouter(authBloc);

  runApp(EchoApp(
    authRepository: authRepository,
    authBloc: authBloc,
    userProfileRepository: userProfileRepository,
    postRepository: postRepository,
    followRepository: followRepository,
    router: router,
  ));
}

/// Root widget of the Echo application.
///
/// Wires the [AuthRepository] and [AuthBloc] into the widget tree so all
/// descendant screens can access them via [context.read].
class EchoApp extends StatelessWidget {
  const EchoApp({
    super.key,
    required this.authRepository,
    required this.authBloc,
    required this.userProfileRepository,
    required this.postRepository,
    required this.followRepository,
    required this.router,
  });

  /// The backing [AuthRepository] exposed to child widgets.
  final AuthRepository authRepository;

  /// The global [AuthBloc] managing authentication state.
  final AuthBloc authBloc;

  /// The backing [UserProfileRepository] exposed to child widgets.
  final UserProfileRepository userProfileRepository;

  /// The backing [PostRepository] exposed to child widgets.
  final PostRepository postRepository;

  /// The backing [FollowRepository] exposed to child widgets.
  final FollowRepository followRepository;

  /// The [GoRouter] instance created from [createRouter].
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<UserProfileRepository>.value(
            value: userProfileRepository),
        RepositoryProvider<PostRepository>.value(value: postRepository),
        RepositoryProvider<FollowRepository>.value(value: followRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              repository: context.read<UserProfileRepository>(),
            ),
          ),
          BlocProvider<PostBloc>(
            create: (context) => PostBloc(
              repository: context.read<PostRepository>(),
              followRepository: context.read<FollowRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Echo',
          theme: AppTheme.dark,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
