import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/view/auth_navigation.dart';

class WritePostButton extends StatelessWidget {
  const WritePostButton({super.key});

  static const String label = 'Écrire';
  static const double iconSize = 22;

  Future<void> _openNewPost(BuildContext context) async {
    final signedIn = await context.ensureSignedIn();
    if (signedIn && context.mounted) {
      await context.push(AppRoutes.newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.fab),
        boxShadow: AppShadows.fab,
      ),
      child: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openNewPost(context),
        icon: const Icon(Icons.edit_rounded, size: iconSize),
        label: const Text(label),
      ),
    );
  }
}
