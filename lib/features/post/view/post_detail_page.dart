import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/status_view.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../feed/cubit/feed_cubit.dart';
import '../cubit/post_detail_cubit.dart';
import '../cubit/post_detail_state.dart';
import 'comment_input_bar.dart';
import 'comments_section.dart';
import 'post_detail_header.dart';
import 'post_detail_texts.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId, this.initialPost});

  final String postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailCubit>(
      create: (context) => PostDetailCubit(
        postRepository: context.read<PostRepository>(),
        commentRepository: context.read<CommentRepository>(),
        postId: postId,
        initialPost: initialPost,
      )..load(),
      child: const PostDetailView(),
    );
  }
}

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealNewComment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppDurations.appear,
        curve: AppCurves.appear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              current.post != null && previous.post != current.post,
          listener: (context, state) {
            final post = state.post;
            if (post != null) {
              context.read<FeedCubit>().replacePost(post);
            }
          },
        ),
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              current.sendFailure != null &&
              previous.sendFailure != current.sendFailure,
          listener: (context, state) {
            final failure = state.sendFailure;
            if (failure != null) {
              context.showErrorSnackBar(failure.message);
            }
          },
        ),
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              !previous.hasSessionFailure && current.hasSessionFailure,
          listener: (context, _) => context.read<AuthCubit>().sessionExpired(),
        ),
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              current.highlightedCommentId != null &&
              previous.highlightedCommentId != current.highlightedCommentId,
          listener: (context, _) => _revealNewComment(),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(PostDetailTexts.title)),
        body: BlocBuilder<PostDetailCubit, PostDetailState>(
          builder: (context, state) {
            final hasPost = state.post != null;
            return Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppDurations.stateSwitch,
                    switchInCurve: AppCurves.stateSwitch,
                    switchOutCurve: AppCurves.stateSwitch,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      fit: StackFit.expand,
                      children: [...previousChildren, ?currentChild],
                    ),
                    child: _PostDetailBody(
                      key: ValueKey(_bodyKeyFor(state)),
                      state: state,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
                if (hasPost) const CommentBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  String _bodyKeyFor(PostDetailState state) {
    if (state.post != null) {
      return 'article';
    }
    return state.postStatus == PostDetailStatus.failure
        ? 'erreur'
        : 'chargement';
  }
}

class _PostDetailBody extends StatelessWidget {
  const _PostDetailBody({
    super.key,
    required this.state,
    required this.scrollController,
  });

  static const double topPadding = AppSpacing.xs;

  final PostDetailState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final post = state.post;
    if (post == null) {
      if (state.postStatus == PostDetailStatus.failure) {
        final failure = state.postFailure ?? const UnknownFailure();
        return ErrorView(
          title: failure is NotFoundFailure
              ? PostDetailTexts.notFoundTitle
              : PostDetailTexts.loadErrorTitle,
          failure: failure,
          onRetry: context.read<PostDetailCubit>().retryPost,
        );
      }
      return const Center(
        child: SizedBox.square(
          dimension: AppSizes.pageProgress,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SingleChildScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.detailHorizontal,
        topPadding,
        AppSpacing.detailHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostDetailHeader(post: post),
          CommentsSection(state: state),
        ],
      ),
    );
  }
}
