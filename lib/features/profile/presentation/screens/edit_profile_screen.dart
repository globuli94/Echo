// lib/features/profile/presentation/screens/edit_profile_screen.dart
//
// EditProfileScreen — allows the authenticated user to update display name
// and bio. Pre-fills fields from the current ProfileLoaded state.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Screen for editing display name and bio.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    final profile =
        profileState is ProfileLoaded ? profileState.profile : null;
    _displayNameController =
        TextEditingController(text: profile?.displayName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSave() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            uid: authState.user.uid,
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.of(context).pop();
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isUpdating = state is ProfileUpdating;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                    ),
                    maxLines: 3,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 24),
                  if (isUpdating)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _onSave,
                      child: const Text('Save'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
