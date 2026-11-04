import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final limit = maxLength;
    final icon = prefixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.labelToField),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            errorMaxLines: 3,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: AppSizes.fieldIcon),
            suffixIcon: suffix,
            counter: limit == null
                ? null
                : TrimmedLengthCounter(controller: controller, maxLength: limit),
          ),
        ),
      ],
    );
  }
}

class TrimmedLengthCounter extends StatelessWidget {
  const TrimmedLengthCounter({
    super.key,
    required this.controller,
    required this.maxLength,
  });

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final length = value.text.trim().length;
        final isOverLimit = length > maxLength;
        return Text(
          '$length/$maxLength',
          style: context.textTheme.labelSmall?.copyWith(
            color: isOverLimit ? context.colorScheme.error : null,
          ),
        );
      },
    );
  }
}
