import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  static const String title = 'Article';

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: const Text(title)),
      body: const SizedBox.shrink(),
    );
  }
}
