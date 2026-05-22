// lib/core/router/app_router.dart
//
// AppRouter — GoRouter configuration with auth-state redirect.
// Pass [AuthBloc] to [createRouter]; the router refreshes on every state change
// and redirects unauthenticated users to /login.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

/// A [ChangeNotifier] that forwards [AuthBloc] state changes to [GoRouter].
///
/// [GoRouter.refreshListenable] accepts a [Listenable]; this class bridges the
/// BLoC stream to that interface.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
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
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
