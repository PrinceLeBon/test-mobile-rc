import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

extension AppSnackBar on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: AppDurations.snackBar,
          content: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppSizes.fieldIcon,
                color: appColors.snackBarErrorIcon,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
