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
    this.iconScale,
  });

  final IconData icon;
  final int count;
  final Color foregroundColor;
  final Color backgroundColor;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Animation<double>? iconScale;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: AppSizes.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
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
    final chip = Material(
      color: backgroundColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: pressHandler == null
          ? content
          : InkWell(onTap: pressHandler, child: content),
    );

    return Semantics(
      button: pressHandler != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: pressHandler == null
          ? chip
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: pressHandler,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
                child: Center(widthFactor: 1, heightFactor: 1, child: chip),
              ),
            ),
    );
  }

  Widget _buildIcon() {
    final iconWidget = Icon(
      icon,
      size: AppSizes.chipIcon,
      color: foregroundColor,
    );
    final scale = iconScale;
    return scale == null
        ? iconWidget
        : ScaleTransition(scale: scale, child: iconWidget);
  }
}

class LikeChip extends StatefulWidget {
  const LikeChip({
    super.key,
    required this.count,
    this.isLiked = false,
    this.onPressed,
  });

  static const String likeLabel = 'J’aime';
  static const String unlikeLabel = 'Je n’aime plus';
  static const double pulseScale = 1.3;

  final int count;
  final bool isLiked;
  final VoidCallback? onPressed;

  @override
  State<LikeChip> createState() => _LikeChipState();
}

class _LikeChipState extends State<LikeChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: AppDurations.like,
  );
  late final Animation<double> _iconScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1, end: LikeChip.pulseScale),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: LikeChip.pulseScale, end: 1),
      weight: 1,
    ),
  ]).animate(CurvedAnimation(parent: _pulseController, curve: AppCurves.like));

  @override
  void didUpdateWidget(covariant LikeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final scheme = context.colorScheme;
    final isLiked = widget.isLiked;
    final count = widget.count;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isLiked ? 1 : 0),
      duration: AppDurations.likeColor,
      curve: AppCurves.likeColor,
      builder: (context, likedProgress, _) {
        return PostStatChip(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          count: count,
          foregroundColor: Color.lerp(
            scheme.onSurfaceVariant,
            appColors.liked,
            likedProgress,
          )!,
          backgroundColor: Color.lerp(
            scheme.surfaceContainer,
            appColors.likedContainer,
            likedProgress,
          )!,
          semanticLabel:
              '${isLiked ? LikeChip.unlikeLabel : LikeChip.likeLabel}, $count',
          onPressed: widget.onPressed,
          iconScale: _iconScale,
        );
      },
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
