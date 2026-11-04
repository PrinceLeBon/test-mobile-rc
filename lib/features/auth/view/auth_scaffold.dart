import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_logo.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
    this.children = const [],
    this.footer,
  });

  final String title;
  final String subtitle;
  final bool showLogo;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final footerWidget = footer;

    return Scaffold(
      backgroundColor: scheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppSizes.authGradientHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primaryContainer, scheme.surface],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.authHorizontal,
                    kToolbarHeight + AppSpacing.xs,
                    AppSpacing.authHorizontal,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      if (showLogo) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppLogo(
                            size: AppLogoSize.large,
                            ringColor: scheme.primaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      Text(title, style: textTheme.displaySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.headerToFirstField),
                      ...children,
                    ],
                  ),
                ),
                if (footerWidget != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.authHorizontal,
                        0,
                        AppSpacing.authHorizontal,
                        AppSpacing.xs,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: footerWidget,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onAction,
  });

  final String question;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
