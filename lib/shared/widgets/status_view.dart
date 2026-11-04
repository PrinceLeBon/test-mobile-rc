import 'package:flutter/material.dart';

import '../../core/error/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_tonal_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.failure,
    required this.onRetry,
  });

  static const String retryLabel = 'Réessayer';

  final String title;
  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return _StatusLayout(
      icon: failure is NetworkFailure
          ? Icons.cloud_off_rounded
          : Icons.error_outline_rounded,
      iconColor: scheme.error,
      circleColor: scheme.errorContainer,
      title: title,
      message: failure.message,
      action: AppTonalButton(
        label: retryLabel,
        icon: Icons.refresh_rounded,
        onPressed: onRetry,
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.article_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      icon: icon,
      iconColor: context.appColors.brand,
      circleColor: context.colorScheme.primaryContainer,
      title: title,
      message: message,
      action: action,
    );
  }
}

class _StatusLayout extends StatelessWidget {
  const _StatusLayout({
    required this.icon,
    required this.iconColor,
    required this.circleColor,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final actionWidget = action;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.statusMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.statusCircle,
                height: AppSizes.statusCircle,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppSizes.statusIcon, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionWidget != null) ...[
                const SizedBox(height: AppSpacing.xl),
                actionWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
