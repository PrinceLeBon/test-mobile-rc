import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_tonal_button.dart';
import '../cubit/post_detail_cubit.dart';
import '../cubit/post_detail_state.dart';
import 'comment_tile.dart';
import 'post_detail_texts.dart';

class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key, required this.state});

  static const double dividerTopGap = AppSpacing.xl;
  static const double dividerBottomGap = AppSpacing.lg;

  final PostDetailState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: dividerTopGap),
        const Divider(height: 1),
        const SizedBox(height: dividerBottomGap),
        _CommentsHeading(count: state.post?.commentsCount ?? 0),
        const SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: AppDurations.stateSwitch,
          switchInCurve: AppCurves.stateSwitch,
          switchOutCurve: AppCurves.stateSwitch,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topCenter,
            children: [...previousChildren, ?currentChild],
          ),
          child: switch (state.commentsStatus) {
            CommentsStatus.loading => const _CommentsLoading(
              key: ValueKey('chargement'),
            ),
            CommentsStatus.failure => const _CommentsError(
              key: ValueKey('erreur'),
            ),
            CommentsStatus.success when state.comments.isEmpty =>
              const _CommentsMessage(
                key: ValueKey('vide'),
                message: PostDetailTexts.commentsEmpty,
              ),
            CommentsStatus.success => _CommentsList(
              key: const ValueKey('liste'),
              state: state,
            ),
          },
        ),
      ],
    );
  }
}

class _CommentsHeading extends StatelessWidget {
  const _CommentsHeading({required this.count});

  static const double countHeight = 22;

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Row(
      children: [
        Text(
          PostDetailTexts.commentsTitle,
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          height: countHeight,
          constraints: const BoxConstraints(minWidth: countHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            '$count',
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentsLoading extends StatelessWidget {
  const _CommentsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: SizedBox.square(
          dimension: AppSizes.pageProgress,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _CommentsMessage extends StatelessWidget {
  const _CommentsMessage({super.key, required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final actionWidget = action;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionWidget != null) ...[
            const SizedBox(height: AppSpacing.md),
            actionWidget,
          ],
        ],
      ),
    );
  }
}

class _CommentsError extends StatelessWidget {
  const _CommentsError({super.key});

  @override
  Widget build(BuildContext context) {
    return _CommentsMessage(
      message: PostDetailTexts.commentsError,
      action: AppTonalButton(
        label: PostDetailTexts.retry,
        icon: Icons.refresh_rounded,
        onPressed: context.read<PostDetailCubit>().loadComments,
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({super.key, required this.state});

  static const double gap = AppSpacing.lg;

  final PostDetailState state;

  @override
  Widget build(BuildContext context) {
    final comments = state.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < comments.length; index++) ...[
          if (index > 0) const SizedBox(height: gap),
          CommentTile(
            key: ValueKey(comments[index].id),
            comment: comments[index],
            isHighlighted: comments[index].id == state.highlightedCommentId,
          ),
        ],
      ],
    );
  }
}
