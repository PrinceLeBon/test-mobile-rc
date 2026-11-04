import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_tonal_button.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  static const String title = 'Blog';
  static const String loginLabel = 'Se connecter';

  @override
  Widget build(BuildContext context) {
    final background = context.colorScheme.surfaceContainerLow;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        centerTitle: false,
        titleSpacing: AppSpacing.feedHorizontal,
        title: Row(
          children: [
            AppLogo(ringColor: background),
            const SizedBox(width: AppSpacing.sm),
            const Text(title),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppTonalButton(
              label: loginLabel,
              height: AppSizes.compactButtonHeight,
              onPressed: () => context.push(AppRoutes.login),
            ),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
