import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._repository) : super(const FeedState());

  final PostRepository _repository;
  int _requestGeneration = 0;

  Future<void> loadInitial() async {
    if (state.status == FeedStatus.loading) {
      return;
    }
    final generation = ++_requestGeneration;
    emit(const FeedState(status: FeedStatus.loading));

    final result = await _repository.fetchPage(skip: 0);
    if (isClosed || generation != _requestGeneration) {
      return;
    }
    result.fold(
      (failure) =>
          emit(FeedState(status: FeedStatus.failure, failure: failure)),
      (page) => emit(_firstPageState(page)),
    );
  }

  Future<void> refresh() async {
    if (state.status != FeedStatus.success) {
      return loadInitial();
    }
    if (state.isRefreshing) {
      return;
    }
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        refreshFailure: () => null,
      ),
    );

    final result = await _repository.fetchPage(skip: 0);
    if (isClosed || generation != _requestGeneration) {
      return;
    }
    result.fold((failure) {
      if (state.posts.isEmpty) {
        emit(FeedState(status: FeedStatus.failure, failure: failure));
        return;
      }
      emit(state.copyWith(isRefreshing: false, refreshFailure: () => failure));
    }, (page) => emit(_firstPageState(page)));
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) {
      return;
    }
    final generation = _requestGeneration;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _repository.fetchPage(skip: state.posts.length);
    if (isClosed || generation != _requestGeneration) {
      return;
    }
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, loadMoreFailure: () => failure),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingMore: false,
          posts: _appendNewPosts(state.posts, page),
          hasReachedEnd: _isLastPage(page),
        ),
      ),
    );
  }

  Future<void> retryLoadMore() async {
    if (state.loadMoreFailure == null) {
      return;
    }
    emit(state.copyWith(loadMoreFailure: () => null));
    await loadMore();
  }

  FeedState _firstPageState(List<Post> page) {
    return FeedState(
      status: FeedStatus.success,
      posts: page,
      hasReachedEnd: _isLastPage(page),
    );
  }

  bool _isLastPage(List<Post> page) => page.length < PostRepository.pageSize;

  List<Post> _appendNewPosts(List<Post> current, List<Post> page) {
    final knownIds = current.map((post) => post.id).toSet();
    return [...current, ...page.where((post) => !knownIds.contains(post.id))];
  }
}
