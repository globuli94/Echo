// lib/main.dart
//
// Application entry point. Initialises Firebase, wires up repositories and
// BLoCs, and mounts the root widget.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'firebase/firebase_options.dart';

/// Initialises Firebase and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final dataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: FirebaseFirestore.instance,
  );
  final authRepository = AuthRepositoryImpl(dataSource: dataSource);
  final authBloc = AuthBloc(repository: authRepository)
    ..add(const AuthStarted());
  final router = createRouter(authBloc);

  runApp(EchoApp(
    authRepository: authRepository,
    authBloc: authBloc,
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
    required this.router,
  });

  /// The backing [AuthRepository] exposed to child widgets.
  final AuthRepository authRepository;

  /// The global [AuthBloc] managing authentication state.
  final AuthBloc authBloc;

  /// The [GoRouter] instance created from [createRouter].
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
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
