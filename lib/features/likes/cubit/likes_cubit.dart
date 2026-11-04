import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/like_repository.dart';
import 'likes_state.dart';

class LikesCubit extends Cubit<LikesState> {
  LikesCubit(this._repository) : super(const LikesState());

  final LikeRepository _repository;
  final Set<String> _checkedPostIds = {};
  bool _isUserKnown = false;
  String? _userId;
  int _userGeneration = 0;

  bool get isSignedIn => _userId != null;

  Future<void> userChanged(String? userId) async {
    if (_isUserKnown && userId == _userId) {
      return;
    }
    _isUserKnown = true;
    _userId = userId;
    _userGeneration++;
    _checkedPostIds.clear();
    emit(
      state.copyWith(
        byPostId: state.byPostId.map(
          (postId, status) =>
              MapEntry(postId, status.copyWith(liked: false, isPending: false)),
        ),
      ),
    );
    if (userId != null) {
      await _loadPersonalLikes(state.byPostId.keys.toList());
    }
  }

  Future<void> registerPosts(
    List<Post> posts, {
    bool reloadPersonalLikes = false,
  }) async {
    if (posts.isEmpty) {
      return;
    }
    final updated = Map<String, PostLikeStatus>.of(state.byPostId);
    for (final post in posts) {
      final known = updated[post.id];
      if (known == null) {
        updated[post.id] = PostLikeStatus(
          likesCount: post.likesCount,
          registeredCount: post.likesCount,
        );
      } else if (!known.isPending && known.registeredCount != post.likesCount) {
        updated[post.id] = known.copyWith(
          likesCount: post.likesCount,
          registeredCount: post.likesCount,
        );
      }
    }
    emit(state.copyWith(byPostId: updated));

    final postIdsToCheck = posts
        .map((post) => post.id)
        .where(
          (postId) => reloadPersonalLikes || !_checkedPostIds.contains(postId),
        )
        .toSet()
        .toList();
    if (_isUserKnown && isSignedIn && postIdsToCheck.isNotEmpty) {
      await _loadPersonalLikes(postIdsToCheck);
    }
  }

  Future<void> toggle(String postId) async {
    final current = state.byPostId[postId];
    if (current == null || current.isPending || !isSignedIn) {
      return;
    }
    final generation = _userGeneration;
    final willLike = !current.liked;
    final optimisticCount = willLike
        ? current.likesCount + 1
        : (current.likesCount - 1).clamp(0, current.likesCount);
    emit(
      _withStatus(
        postId,
        current.copyWith(
          liked: willLike,
          likesCount: optimisticCount,
          isPending: true,
        ),
      ),
    );

    final result = await _repository.toggle(postId);
    if (isClosed) {
      return;
    }
    final latest = state.byPostId[postId] ?? current;
    result.fold(
      (failure) {
        final restored = latest.copyWith(
          liked: generation == _userGeneration && current.liked,
          likesCount: current.likesCount,
          isPending: false,
        );
        emit(state.withFailure(failure, _statusesWith(postId, restored)));
      },
      (like) => emit(
        _withStatus(
          postId,
          latest.copyWith(
            liked: generation == _userGeneration && like.liked,
            likesCount: like.likesCount,
            isPending: false,
          ),
        ),
      ),
    );
  }

  Future<void> _loadPersonalLikes(List<String> postIds) async {
    if (postIds.isEmpty) {
      return;
    }
    final generation = _userGeneration;
    _checkedPostIds.addAll(postIds);
    final result = await _repository.fetchLikedPostIds(postIds);
    if (isClosed || generation != _userGeneration) {
      return;
    }
    result.fold(
      (failure) {
        _checkedPostIds.removeAll(postIds);
        if (failure is SessionFailure) {
          emit(state.withFailure(failure, state.byPostId));
        }
      },
      (likedPostIds) {
        final updated = Map<String, PostLikeStatus>.of(state.byPostId);
        for (final postId in postIds) {
          final known = updated[postId];
          if (known == null || known.isPending) {
            continue;
          }
          updated[postId] = known.copyWith(
            liked: likedPostIds.contains(postId),
          );
        }
        emit(state.copyWith(byPostId: updated));
      },
    );
  }

  LikesState _withStatus(String postId, PostLikeStatus status) {
    return state.copyWith(byPostId: _statusesWith(postId, status));
  }

  Map<String, PostLikeStatus> _statusesWith(
    String postId,
    PostLikeStatus status,
  ) {
    return Map<String, PostLikeStatus>.of(state.byPostId)..[postId] = status;
  }
}
