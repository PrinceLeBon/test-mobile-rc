import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_tonal_button.dart';
import '../cubit/post_detail_cubit.dart';
import '../cubit/post_detail_state.dart';
import 'post_detail_texts.dart';

class DeletePostDialog extends StatelessWidget {
  const DeletePostDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final cubit = context.read<PostDetailCubit>();
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider<PostDetailCubit>.value(
        value: cubit,
        child: const DeletePostDialog(),
      ),
    );
    return deleted ?? false;
  }

  Future<void> _confirm(BuildContext context) async {
    final deleted = await context.read<PostDetailCubit>().deletePost();
    if (context.mounted) {
      Navigator.of(context).pop(deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return BlocBuilder<PostDetailCubit, PostDetailState>(
      buildWhen: (previous, current) =>
          previous.isDeleting != current.isDeleting,
      builder: (context, state) {
        final isDeleting = state.isDeleting;
        return PopScope(
          canPop: !isDeleting,
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(AppSpacing.xl),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.dialogIconCircle,
                  height: AppSizes.dialogIconCircle,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: AppSizes.dialogIcon,
                    color: scheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  PostDetailTexts.deleteDialogTitle,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  PostDetailTexts.deleteDialogMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppTonalButton(
                        label: PostDetailTexts.deleteCancel,
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppPrimaryButton(
                        label: PostDetailTexts.deleteConfirm,
                        height: AppSizes.secondaryButtonHeight,
                        isDestructive: true,
                        isLoading: isDeleting,
                        onPressed: () => _confirm(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
