import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/relative_date_formatter.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/post_stat_chip.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../likes/view/post_like_button.dart';

class PostDetailHeader extends StatelessWidget {
  const PostDetailHeader({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserAvatar(username: post.authorName, size: AvatarSize.detail),
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
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(post.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(post.body, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            PostLikeButton(post: post),
            const SizedBox(width: AppSpacing.xs),
            CommentCountChip(count: post.commentsCount),
          ],
        ),
      ],
    );
  }
}
