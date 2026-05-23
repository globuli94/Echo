// lib/core/router/app_router.dart
//
// AppRouter — GoRouter configuration with auth-state redirect.
// Pass [AuthBloc] to [createRouter]; the router refreshes on every state change
// and redirects unauthenticated users to /login.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/follow/domain/repositories/follow_repository.dart';
import '../../features/follow/presentation/bloc/follow_bloc.dart';
import '../../features/follow/presentation/bloc/follow_event.dart';
import '../../features/follow/presentation/bloc/follow_list_bloc.dart';
import '../../features/follow/presentation/screens/followers_screen.dart';
import '../../features/follow/presentation/screens/following_screen.dart';
import '../../features/navigation/presentation/screens/main_shell.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/presentation/bloc/create_post_bloc.dart';
import '../../features/posts/presentation/bloc/user_posts_bloc.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// A [ChangeNotifier] that forwards [AuthBloc] state changes to [GoRouter].
///
/// [GoRouter.refreshListenable] accepts a [Listenable]; this class bridges the
/// BLoC stream to that interface.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((state) {
      if (state is AuthAuthenticated ||
          state is AuthUnauthenticated ||
          state is AuthInitial) {
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Creates and returns the app [GoRouter].
///
/// [authBloc] is used both as the [GoRouter.refreshListenable] source and
/// inside the redirect callback to read the current auth state.
GoRouter createRouter(AuthBloc authBloc) {
  final notifier = _AuthNotifier(authBloc);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;
      final isAuthPage = location == '/login' || location == '/signup';

      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        return isAuthPage ? null : '/login';
      }
      if (authState is AuthAuthenticated) {
        return isAuthPage ? '/home' : null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final authState = context.read<AuthBloc>().state;
          final currentUid =
              authState is AuthAuthenticated ? authState.user.uid : '';
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>(
                create: (ctx) => ProfileBloc(
                  repository: ctx.read<UserProfileRepository>(),
                ),
              ),
              BlocProvider<UserPostsBloc>(
                create: (ctx) => UserPostsBloc(
                  repository: ctx.read<PostRepository>(),
                ),
              ),
              BlocProvider<FollowBloc>(
                create: (ctx) => FollowBloc(
                  repository: ctx.read<FollowRepository>(),
                )..add(FollowStatusSubscribed(
                    currentUid: currentUid,
                    targetUid: uid,
                  )),
              ),
            ],
            child: ProfileScreen(uid: uid),
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => BlocProvider<CreatePostBloc>(
          create: (ctx) => CreatePostBloc(
            repository: ctx.read<PostRepository>(),
          ),
          child: const CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: '/followers/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return BlocProvider<FollowListBloc>(
            create: (ctx) => FollowListBloc(
              followRepository: ctx.read<FollowRepository>(),
              profileRepository: ctx.read<UserProfileRepository>(),
            ),
            child: FollowersScreen(profileUid: uid),
          );
        },
      ),
      GoRoute(
        path: '/following/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return BlocProvider<FollowListBloc>(
            create: (ctx) => FollowListBloc(
              followRepository: ctx.read<FollowRepository>(),
              profileRepository: ctx.read<UserProfileRepository>(),
            ),
            child: FollowingScreen(profileUid: uid),
          );
        },
      ),
    ],
  );
}
