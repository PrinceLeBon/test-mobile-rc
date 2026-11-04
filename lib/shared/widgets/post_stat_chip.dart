import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class PostStatChip extends StatelessWidget {
  const PostStatChip({
    super.key,
    required this.icon,
    required this.count,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.semanticLabel,
    this.onPressed,
  });

  final IconData icon;
  final int count;
  final Color foregroundColor;
  final Color backgroundColor;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: AppSizes.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.chipIcon, color: foregroundColor),
          const SizedBox(width: AppSpacing.iconGap),
          Text(
            '$count',
            style: context.textTheme.labelMedium?.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
    final pressHandler = onPressed;

    return Semantics(
      button: pressHandler != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: pressHandler == null
            ? content
            : InkWell(onTap: pressHandler, child: content),
      ),
    );
  }
}

class LikeChip extends StatelessWidget {
  const LikeChip({
    super.key,
    required this.count,
    this.isLiked = false,
    this.onPressed,
  });

  static const String likeLabel = 'J’aime';
  static const String unlikeLabel = 'Je n’aime plus';

  final int count;
  final bool isLiked;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final scheme = context.colorScheme;

    return PostStatChip(
      icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      count: count,
      foregroundColor: isLiked ? appColors.liked : scheme.onSurfaceVariant,
      backgroundColor: isLiked
          ? appColors.likedContainer
          : scheme.surfaceContainer,
      semanticLabel: '${isLiked ? unlikeLabel : likeLabel}, $count',
      onPressed: onPressed,
    );
  }
}

class CommentCountChip extends StatelessWidget {
  const CommentCountChip({super.key, required this.count});

  final int count;

  static String semanticLabelFor(int count) =>
      count > 1 ? '$count commentaires' : '$count commentaire';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return PostStatChip(
      icon: Icons.chat_bubble_outline_rounded,
      count: count,
      foregroundColor: scheme.onSurfaceVariant,
      backgroundColor: scheme.surfaceContainer,
      semanticLabel: semanticLabelFor(count),
    );
  }
}
