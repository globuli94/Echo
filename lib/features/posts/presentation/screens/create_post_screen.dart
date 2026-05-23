// lib/features/posts/presentation/screens/create_post_screen.dart
//
// CreatePostScreen — compose and submit a new post with optional image.
// BlocProvider<CreatePostBloc> is provided at the route level in app_router.dart.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context
          .read<CreatePostBloc>()
          .add(CreatePostImagePicked(imagePath: picked.path));
    }
  }

  void _submit(String authorId, String? imagePath) {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    context.read<CreatePostBloc>().add(
          CreatePostSubmitted(authorId: authorId, content: content),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final authorId =
        authState is AuthAuthenticated ? authState.user.uid : '';

    return BlocListener<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          context.pop();
        } else if (state is CreatePostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<CreatePostBloc, CreatePostState>(
        builder: (context, state) {
          final isSubmitting = state is CreatePostSubmitting;
          final imagePath =
              state is CreatePostDraft ? state.imagePath : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('New Post'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 3,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 12),
                  if (imagePath != null) ...[
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey,
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove image',
                          onPressed: isSubmitting
                              ? null
                              : () => context
                                  .read<CreatePostBloc>()
                                  .add(const CreatePostImageCleared()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextButton.icon(
                    onPressed: isSubmitting ? null : _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add photo'),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _contentController,
                    builder: (context, value, _) {
                      final canSubmit =
                          value.text.trim().isNotEmpty && !isSubmitting;
                      return FilledButton(
                        onPressed: canSubmit
                            ? () => _submit(authorId, imagePath)
                            : null,
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Post'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
