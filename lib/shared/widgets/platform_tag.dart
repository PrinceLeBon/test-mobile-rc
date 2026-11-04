import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class PlatformTag extends StatelessWidget {
  const PlatformTag({super.key});

  static const String label = 'Testé sur iOS · simulateur iPhone 17 Pro';
  static const double dotSize = 6;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.iconGap),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
