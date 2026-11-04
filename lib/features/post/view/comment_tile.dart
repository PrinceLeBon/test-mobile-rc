import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/relative_date_formatter.dart';
import '../../../data/models/comment.dart';
import '../../../shared/widgets/appear_animation.dart';
import '../../../shared/widgets/user_avatar.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.isHighlighted = false,
  });

  static const double highlightRadius = 16;
  static const double highlightOverflow = AppSpacing.sm;

  final Comment comment;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final content = _CommentContent(comment: comment);
    if (!isHighlighted) {
      return content;
    }
    return AppearAnimation(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: -highlightOverflow,
            top: -highlightOverflow,
            right: -highlightOverflow,
            bottom: -highlightOverflow,
            child: _FadingHighlight(),
          ),
          content,
        ],
      ),
    );
  }
}

class _FadingHighlight extends StatelessWidget {
  const _FadingHighlight();

  @override
  Widget build(BuildContext context) {
    final highlightColor = context.colorScheme.primaryContainer;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: AppDurations.newCommentHighlight,
      curve: AppCurves.newCommentHighlight,
      builder: (context, opacity, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: highlightColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(CommentTile.highlightRadius),
          ),
        );
      },
    );
  }
}

class _CommentContent extends StatelessWidget {
  const _CommentContent({required this.comment});

  static const double nameToTextGap = 2;

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(username: comment.authorName, size: AvatarSize.comment),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      comment.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    RelativeDateFormatter.format(comment.createdAt),
                    maxLines: 1,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: nameToTextGap),
              Text(comment.text, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
