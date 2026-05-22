// lib/features/auth/presentation/screens/home_screen.dart
//
// HomeScreen — placeholder authenticated home screen.
// Will be replaced by the full feed implementation in a later ticket.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Placeholder home screen shown after successful authentication.
///
/// Provides a sign-out button that dispatches [SignOutRequested] to
/// [AuthBloc]; the auth-state stream handles the resulting navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
          child: const Text('Log Out'),
        ),
      ),
    );
  }
}
