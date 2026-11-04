import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/relative_date_formatter.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/post_stat_chip.dart';
import '../../../shared/widgets/user_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.isLiked = false,
    this.onLikePressed,
  });

  static const int titleMaxLines = 2;
  static const int excerptMaxLines = 3;

  final Post post;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback? onLikePressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostCardAuthor(post: post),
          const SizedBox(height: AppSpacing.sm),
          Text(
            post.title,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            post.body,
            maxLines: excerptMaxLines,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              LikeChip(
                count: post.likesCount,
                isLiked: isLiked,
                onPressed: onLikePressed,
              ),
              const SizedBox(width: AppSpacing.xs),
              CommentCountChip(count: post.commentsCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostCardAuthor extends StatelessWidget {
  const _PostCardAuthor({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Row(
      children: [
        UserAvatar(username: post.authorName),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
              Text(
                RelativeDateFormatter.format(post.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
