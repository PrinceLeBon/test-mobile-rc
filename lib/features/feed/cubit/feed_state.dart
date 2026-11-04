import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/post.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.failure,
    this.loadMoreFailure,
    this.refreshFailure,
  });

  final FeedStatus status;
  final List<Post> posts;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final bool isRefreshing;
  final Failure? failure;
  final Failure? loadMoreFailure;
  final Failure? refreshFailure;

  bool get isEmpty => status == FeedStatus.success && posts.isEmpty;

  bool get hasSessionFailure =>
      failure is SessionFailure ||
      loadMoreFailure is SessionFailure ||
      refreshFailure is SessionFailure;

  bool get canLoadMore =>
      status == FeedStatus.success &&
      !hasReachedEnd &&
      !isLoadingMore &&
      !isRefreshing &&
      loadMoreFailure == null;

  FeedState copyWith({
    FeedStatus? status,
    List<Post>? posts,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    bool? isRefreshing,
    Failure? Function()? failure,
    Failure? Function()? loadMoreFailure,
    Failure? Function()? refreshFailure,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure == null ? this.failure : failure(),
      loadMoreFailure: loadMoreFailure == null
          ? this.loadMoreFailure
          : loadMoreFailure(),
      refreshFailure: refreshFailure == null
          ? this.refreshFailure
          : refreshFailure(),
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    hasReachedEnd,
    isLoadingMore,
    isRefreshing,
    failure,
    loadMoreFailure,
    refreshFailure,
  ];
}
