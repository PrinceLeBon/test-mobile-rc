import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/post.dart';
import '../../../shared/widgets/post_stat_chip.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/auth_navigation.dart';
import '../cubit/likes_cubit.dart';
import '../cubit/likes_state.dart';

class PostLikeButton extends StatelessWidget {
  const PostLikeButton({super.key, required this.post});

  final Post post;

  void _onPressed(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthUnknown) {
      return;
    }
    if (authState is! AuthAuthenticated) {
      context.openLogin();
      return;
    }
    context.read<LikesCubit>().toggle(post.id);
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<LikesCubit, PostLikeStatus?>(
      (cubit) => cubit.state.byPostId[post.id],
    );

    return LikeChip(
      count: status?.likesCount ?? post.likesCount,
      isLiked: status?.liked ?? false,
      onPressed: () => _onPressed(context),
    );
  }
}
