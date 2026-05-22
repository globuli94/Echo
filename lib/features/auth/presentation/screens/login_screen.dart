// lib/features/auth/presentation/screens/login_screen.dart
//
// LoginScreen — entry point for returning users. Supports email/password,
// Google Sign-In, forgot-password, and navigation to sign-up.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Full-screen login form for returning users.
///
/// Listens to [AuthBloc] and reacts to state changes:
/// - [AuthAuthenticated] → navigates to `/home`
/// - [AuthFailure] → shows a [SnackBar] with the error
/// - [ForgotPasswordEmailSent] → shows a [SnackBar] confirming the email
/// - [AuthLoading] → overlays a [CircularProgressIndicator]
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignInWithEmailAndPasswordRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _onGoogleSignInPressed() {
    context.read<AuthBloc>().add(const SignInWithGoogleRequested());
  }

  Future<void> _onForgotPasswordPressed() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _ForgotPasswordDialog(
        emailController: emailController,
        onSubmit: (email) {
          context.read<AuthBloc>().add(ForgotPasswordRequested(email: email));
        },
      ),
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else if (state is ForgotPasswordEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent.')),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 64),
                          Center(
                            child: Image(
                              image: const AssetImage('Echo Logo.png'),
                              height: 96,
                              width: 96,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Echo',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Please enter your email.'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter your password.'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _onLoginPressed,
                            child: const Text('Log In'),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed:
                                  isLoading ? null : _onForgotPasswordPressed,
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _onGoogleSignInPressed,
                            icon: const Icon(Icons.login),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go('/signup'),
                              child: const Text("Don't have an account? Sign up"),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const ColoredBox(
                    color: Colors.black38,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Dialog that collects an email address and dispatches [ForgotPasswordRequested].
class _ForgotPasswordDialog extends StatelessWidget {
  const _ForgotPasswordDialog({
    required this.emailController,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final void Function(String email) onSubmit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(hintText: 'Email'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isNotEmpty) {
              onSubmit(email);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
