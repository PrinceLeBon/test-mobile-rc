import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../feed/cubit/feed_cubit.dart';
import '../cubit/post_detail_cubit.dart';
import 'delete_post_dialog.dart';
import 'post_detail_texts.dart';

class DeletePostAction extends StatelessWidget {
  const DeletePostAction({super.key});

  Future<void> _confirmDeletion(BuildContext context) async {
    final postId = context.read<PostDetailCubit>().state.postId;
    final deleted = await DeletePostDialog.show(context);
    if (!deleted || !context.mounted) {
      return;
    }
    context.read<FeedCubit>().removePost(postId);
    context.showInfoSnackBar(PostDetailTexts.deletedMessage);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.feed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<AuthCubit, String?>(
      (cubit) => switch (cubit.state) {
        AuthAuthenticated(:final user) => user.id,
        _ => null,
      },
    );
    final isAuthor = context.select<PostDetailCubit, bool>(
      (cubit) => cubit.state.post?.isWrittenBy(currentUserId) ?? false,
    );
    final isDeleting = context.select<PostDetailCubit, bool>(
      (cubit) => cubit.state.isDeleting,
    );
    if (!isAuthor) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: PostDetailTexts.deleteTooltip,
      icon: const Icon(Icons.delete_outline_rounded),
      onPressed: isDeleting ? null : () => _confirmDeletion(context),
    );
  }
}
