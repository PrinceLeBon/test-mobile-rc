import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/validation_rules.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/auth_navigation.dart';
import '../cubit/post_detail_cubit.dart';
import 'post_detail_texts.dart';

class CommentBar extends StatelessWidget {
  const CommentBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return AnimatedSwitcher(
          duration: AppDurations.stateSwitch,
          switchInCurve: AppCurves.stateSwitch,
          switchOutCurve: AppCurves.stateSwitch,
          child: switch (authState) {
            AuthAuthenticated() => const CommentInputBar(
              key: ValueKey('saisie'),
            ),
            AuthUnauthenticated() => const VisitorCommentBar(
              key: ValueKey('visiteur'),
            ),
            AuthUnknown() => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _CommentBarFrame extends StatelessWidget {
  const _CommentBarFrame({required this.child, this.verticalPadding});

  final Widget child;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: AppShadows.commentBar,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          child: child,
        ),
      ),
    );
  }
}

class VisitorCommentBar extends StatelessWidget {
  const VisitorCommentBar({super.key});

  @override
  Widget build(BuildContext context) {
    return _CommentBarFrame(
      verticalPadding: AppSpacing.md,
      child: Row(
        children: [
          Expanded(
            child: Text(
              PostDetailTexts.visitorInvite,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: context.openLogin,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppSizes.compactButtonHeight),
              fixedSize: const Size.fromHeight(AppSizes.compactButtonHeight),
            ),
            child: const Text(PostDetailTexts.signIn),
          ),
        ],
      ),
    );
  }
}

class CommentInputBar extends StatefulWidget {
  const CommentInputBar({super.key});

  static const double sendIconSize = 20;
  static const double sendProgressSize = 18;
  static const double focusedBorderWidth = 1.5;
  static const double fieldVerticalPadding = 11;
  static const int maxVisibleLines = 5;

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final sent = await context.read<PostDetailCubit>().addComment(
      _controller.text,
    );
    if (sent && mounted) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSending = context.select<PostDetailCubit, bool>(
      (cubit) => cubit.state.isSendingComment,
    );

    return _CommentBarFrame(
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          final trimmedLength = value.text.trim().length;
          final canSend =
              !isSending && ValidationRules.isCommentValid(value.text);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CommentLengthCounter(length: trimmedLength),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _CommentField(
                      controller: _controller,
                      isReadOnly: isSending,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _SendButton(
                    isSending: isSending,
                    onPressed: canSend ? _send : null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentLengthCounter extends StatelessWidget {
  const _CommentLengthCounter({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final isVisible = length >= ValidationRules.commentCounterThreshold;
    final isTooLong = length > ValidationRules.commentMaxLength;

    return AnimatedSize(
      duration: AppDurations.appear,
      curve: AppCurves.appear,
      alignment: Alignment.bottomCenter,
      child: isVisible
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.xxs,
                right: AppSizes.sendButton + AppSpacing.xs,
              ),
              child: Text(
                '$length/${ValidationRules.commentMaxLength}',
                textAlign: TextAlign.right,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isTooLong ? context.colorScheme.error : null,
                ),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.controller, required this.isReadOnly});

  final TextEditingController controller;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textStyle = context.textTheme.bodyMedium;
    OutlineInputBorder pillBorder(BorderSide side) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
      borderSide: side,
    );

    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      minLines: 1,
      maxLines: CommentInputBar.maxVisibleLines,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: textStyle,
      decoration: InputDecoration(
        hintText: PostDetailTexts.commentHint,
        hintStyle: textStyle?.copyWith(color: scheme.onSurfaceVariant),
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainer,
        constraints: const BoxConstraints(
          minHeight: AppSizes.commentFieldMinHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: CommentInputBar.fieldVerticalPadding,
        ),
        border: pillBorder(BorderSide.none),
        enabledBorder: pillBorder(BorderSide.none),
        focusedBorder: pillBorder(
          BorderSide(
            color: context.appColors.brand,
            width: CommentInputBar.focusedBorderWidth,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isSending, required this.onPressed});

  final bool isSending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return IconButton.filled(
      tooltip: PostDetailTexts.send,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSizes.sendButton),
        minimumSize: const Size.square(AppSizes.sendButton),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: isSending
            ? scheme.primary
            : scheme.surfaceContainerHighest,
        disabledForegroundColor: context.appColors.textDisabled,
      ),
      icon: isSending
          ? SizedBox.square(
              dimension: CommentInputBar.sendProgressSize,
              child: CircularProgressIndicator(
                strokeWidth: AppSizes.progressStroke,
                color: scheme.onPrimary,
              ),
            )
          : const Icon(Icons.send_rounded, size: CommentInputBar.sendIconSize),
    );
  }
}
