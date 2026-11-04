import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  static const String title = 'Nouvel article';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: const Text(title)),
      body: const SizedBox.shrink(),
    );
  }
}
