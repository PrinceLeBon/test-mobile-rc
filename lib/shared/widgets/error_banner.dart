import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.fieldIcon,
              color: scheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedErrorBanner extends StatelessWidget {
  const AnimatedErrorBanner({
    super.key,
    required this.message,
    this.spacingBelow = AppSpacing.betweenFields,
  });

  final String? message;
  final double spacingBelow;

  @override
  Widget build(BuildContext context) {
    final currentMessage = message;

    return AnimatedSize(
      duration: AppDurations.appear,
      curve: AppCurves.appear,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: AppDurations.appear,
        switchInCurve: AppCurves.appear,
        child: currentMessage == null
            ? const SizedBox(width: double.infinity)
            : Padding(
                key: ValueKey(currentMessage),
                padding: EdgeInsets.only(bottom: spacingBelow),
                child: ErrorBanner(message: currentMessage),
              ),
      ),
    );
  }
}
