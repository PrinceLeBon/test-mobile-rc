import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_card.dart';

class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({super.key});

  static const int initialCount = 4;

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.skeletonPulse,
  )..repeat(reverse: true);

  late final Animation<double> _progress = CurvedAnimation(
    parent: _pulse,
    curve: AppCurves.skeletonPulse,
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      label: 'Chargement',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final shade = Color.lerp(
              colors.skeletonBase,
              colors.skeletonHighlight,
              _progress.value,
            )!;
            return AppCard(child: _SkeletonContent(shade: shade));
          },
        ),
      ),
    );
  }
}

class _SkeletonContent extends StatelessWidget {
  const _SkeletonContent({required this.shade});

  final Color shade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SkeletonBlock(
              shade: shade,
              width: AppSizes.avatarCard,
              height: AppSizes.avatarCard,
              radius: AppRadius.full,
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBlock(shade: shade, width: 120, height: 12),
                const SizedBox(height: AppSpacing.xs),
                _SkeletonBlock(shade: shade, width: 64, height: 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        FractionallySizedBox(
          widthFactor: 0.85,
          child: _SkeletonBlock(shade: shade, height: 16),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SkeletonBlock(shade: shade, height: 12),
        const SizedBox(height: AppSpacing.xs),
        _SkeletonBlock(shade: shade, height: 12),
        const SizedBox(height: AppSpacing.xs),
        FractionallySizedBox(
          widthFactor: 0.6,
          child: _SkeletonBlock(shade: shade, height: 12),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _SkeletonBlock(
              shade: shade,
              width: 56,
              height: AppSizes.chipHeight,
              radius: AppRadius.full,
            ),
            const SizedBox(width: AppSpacing.xs),
            _SkeletonBlock(
              shade: shade,
              width: 56,
              height: AppSizes.chipHeight,
              radius: AppRadius.full,
            ),
          ],
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.shade,
    required this.height,
    this.width = double.infinity,
    this.radius = AppRadius.small,
  });

  final Color shade;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shade,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
