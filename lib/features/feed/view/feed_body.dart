import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/app_tonal_button.dart';
import '../../../shared/widgets/appear_animation.dart';
import '../../../shared/widgets/platform_tag.dart';
import '../../../shared/widgets/post_card_skeleton.dart';
import '../../../shared/widgets/status_view.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/auth_navigation.dart';
import '../cubit/feed_cubit.dart';
import '../cubit/feed_state.dart';
import 'post_card.dart';

abstract final class FeedTexts {
  static const String loadErrorTitle = 'Impossible de charger les articles';
  static const String emptyTitle = 'Aucun article pour l’instant';
  static const String emptyMessage = 'Soyez le premier à partager une idée.';
  static const String signIn = 'Se connecter';
  static const String loadMoreError = 'Impossible de charger la suite.';
  static const String retry = 'Réessayer';
  static const String endOfFeed = 'Vous avez tout lu.';
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FeedCubit, FeedState>(
          listenWhen: (previous, current) =>
              current.refreshFailure != null &&
              previous.refreshFailure != current.refreshFailure,
          listener: (context, state) {
            final failure = state.refreshFailure;
            if (failure != null) {
              context.showErrorSnackBar(failure.message);
            }
          },
        ),
        BlocListener<FeedCubit, FeedState>(
          listenWhen: (previous, current) =>
              !previous.hasSessionFailure && current.hasSessionFailure,
          listener: (context, _) => context.read<AuthCubit>().sessionExpired(),
        ),
      ],
      child: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: AppDurations.stateSwitch,
            switchInCurve: AppCurves.stateSwitch,
            switchOutCurve: AppCurves.stateSwitch,
            child: switch (state.status) {
              FeedStatus.initial || FeedStatus.loading => const _FeedSkeletons(
                key: ValueKey('chargement'),
              ),
              FeedStatus.failure => ErrorView(
                key: const ValueKey('erreur'),
                title: FeedTexts.loadErrorTitle,
                failure: state.failure ?? const UnknownFailure(),
                onRetry: context.read<FeedCubit>().loadInitial,
              ),
              FeedStatus.success when state.posts.isEmpty => const _FeedEmpty(
                key: ValueKey('vide'),
              ),
              FeedStatus.success => _FeedList(
                key: const ValueKey('liste'),
                state: state,
              ),
            },
          );
        },
      ),
    );
  }
}

class _FeedSkeletons extends StatelessWidget {
  const _FeedSkeletons({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.feedHorizontal,
        AppSpacing.feedTop,
        AppSpacing.feedHorizontal,
        AppSpacing.feedBottom,
      ),
      itemCount: PostCardSkeleton.initialCount,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.feedCardGap),
      itemBuilder: (_, _) => const PostCardSkeleton(),
    );
  }
}

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final isVisitor = context.select<AuthCubit, bool>(
      (cubit) => cubit.state is AuthUnauthenticated,
    );

    return RefreshIndicator(
      onRefresh: context.read<FeedCubit>().refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: FeedTexts.emptyTitle,
              message: FeedTexts.emptyMessage,
              action: isVisitor
                  ? AppTonalButton(
                      label: FeedTexts.signIn,
                      icon: Icons.login_rounded,
                      onPressed: context.openLogin,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({super.key, required this.state});

  static const double loadMoreThreshold = 600;

  final FeedState state;

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis == Axis.vertical &&
        metrics.extentAfter < loadMoreThreshold) {
      context.read<FeedCubit>().loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final posts = state.posts;

    return RefreshIndicator(
      onRefresh: context.read<FeedCubit>().refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.feedHorizontal,
                AppSpacing.feedTop,
                AppSpacing.feedHorizontal,
                0,
              ),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.feedCardGap),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return AppearAnimation(
                    key: ValueKey(post.id),
                    child: PostCard(
                      post: post,
                      onTap: () => context.push(
                        AppRoutes.postDetail(post.id),
                        extra: post,
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.feedHorizontal,
                0,
                AppSpacing.feedHorizontal,
                AppSpacing.feedBottom,
              ),
              sliver: SliverToBoxAdapter(child: FeedFooter(state: state)),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedFooter extends StatelessWidget {
  const FeedFooter({super.key, required this.state});

  static const double height = 64;

  final FeedState state;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = context.textTheme.bodySmall;

    if (state.loadMoreFailure != null) {
      return SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                FeedTexts.loadMoreError,
                style: mutedStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            TextButton(
              onPressed: context.read<FeedCubit>().retryLoadMore,
              child: const Text(FeedTexts.retry),
            ),
          ],
        ),
      );
    }
    if (state.hasReachedEnd) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          children: [
            Text(FeedTexts.endOfFeed, style: mutedStyle),
            const SizedBox(height: AppSpacing.xxs),
            const PlatformTag(),
          ],
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Center(
        child: state.isLoadingMore
            ? const SizedBox.square(
                dimension: AppSizes.pageProgress,
                child: CircularProgressIndicator(),
              )
            : null,
      ),
    );
  }
}
