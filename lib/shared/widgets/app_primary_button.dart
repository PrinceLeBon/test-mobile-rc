import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.height = AppSizes.primaryButtonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isDestructive ? scheme.error : scheme.primary;
    final foreground = isDestructive ? scheme.onError : scheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(height),
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: isLoading ? background : null,
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: AppSizes.buttonProgress,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizes.progressStroke,
                  color: foreground,
                ),
              )
            : Text(label),
      ),
    );
  }
}
