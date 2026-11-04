import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class AppTonalButton extends StatelessWidget {
  const AppTonalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = AppSizes.secondaryButtonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = FilledButton.styleFrom(
      minimumSize: Size(0, height),
      fixedSize: Size.fromHeight(height),
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    );
    final iconData = icon;

    if (iconData == null) {
      return FilledButton.tonal(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      style: style,
      icon: Icon(iconData, size: AppSizes.fieldIcon),
      label: Text(label),
    );
  }
}
