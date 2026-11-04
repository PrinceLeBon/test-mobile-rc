import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/validation_rules.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/comment_event.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/post_repository.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit({
    required PostRepository postRepository,
    required CommentRepository commentRepository,
    required String postId,
    Post? initialPost,
  }) : _postRepository = postRepository,
       _commentRepository = commentRepository,
       super(
         PostDetailState(
           postId: postId,
           post: initialPost,
           postStatus: initialPost == null
               ? PostDetailStatus.loading
               : PostDetailStatus.success,
         ),
       );

  final PostRepository _postRepository;
  final CommentRepository _commentRepository;
  StreamSubscription<CommentEvent>? _commentEventsSubscription;

  Future<void> load() async {
    await Future.wait([_loadPost(), loadComments()]);
  }

  Future<void> retryPost() async {
    emit(
      state.copyWith(
        postStatus: PostDetailStatus.loading,
        postFailure: () => null,
      ),
    );
    await load();
  }

  Future<void> loadComments() async {
    emit(
      state.copyWith(
        commentsStatus: CommentsStatus.loading,
        commentsFailure: () => null,
      ),
    );
    final result = await _commentRepository.fetchForPost(state.postId);
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) => emit(
        state.copyWith(
          commentsStatus: CommentsStatus.failure,
          commentsFailure: () => failure,
        ),
      ),
      (comments) => emit(
        state.copyWith(
          commentsStatus: CommentsStatus.success,
          comments: comments,
        ),
      ),
    );
  }

  Future<bool> addComment(String rawText) async {
    final text = rawText.trim();
    if (state.isSendingComment || !ValidationRules.isCommentValid(text)) {
      return false;
    }
    emit(state.copyWith(isSendingComment: true, sendFailure: () => null));

    final result = await _commentRepository.create(
      postId: state.postId,
      text: text,
    );
    if (isClosed) {
      return false;
    }
    return result.fold(
      (failure) {
        emit(
          state.copyWith(isSendingComment: false, sendFailure: () => failure),
        );
        return false;
      },
      (comment) {
        final stateWithComment = _isDisplayed(comment.id)
            ? state
            : _withAddedComment(comment);
        emit(
          stateWithComment.copyWith(
            isSendingComment: false,
            highlightedCommentId: () => comment.id,
          ),
        );
        return true;
      },
    );
  }

  void watchComments() {
    _commentEventsSubscription ??= _commentRepository
        .watchForPost(state.postId)
        .listen(_onCommentEvent);
  }

  Future<bool> deletePost() async {
    if (state.isDeleting) {
      return false;
    }
    emit(state.copyWith(isDeleting: true, deleteFailure: () => null));
    final result = await _postRepository.delete(state.postId);
    if (isClosed) {
      return false;
    }
    return result.fold(
      (failure) {
        emit(state.copyWith(isDeleting: false, deleteFailure: () => failure));
        return false;
      },
      (_) {
        emit(state.copyWith(isDeleting: false));
        return true;
      },
    );
  }

  Future<void> _loadPost() async {
    final result = await _postRepository.fetchById(state.postId);
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) {
        final keepsDisplayedPost =
            state.post != null && failure is! NotFoundFailure;
        emit(
          keepsDisplayedPost
              ? state.copyWith(postFailure: () => failure)
              : state.copyWith(
                  post: () => null,
                  postStatus: PostDetailStatus.failure,
                  postFailure: () => failure,
                ),
        );
      },
      (post) => emit(
        state.copyWith(
          post: () => post,
          postStatus: PostDetailStatus.success,
          postFailure: () => null,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _commentEventsSubscription?.cancel();
    _commentEventsSubscription = null;
    return super.close();
  }

  void _onCommentEvent(CommentEvent event) {
    switch (event) {
      case CommentAdded(:final comment):
        _addIncomingComment(comment);
      case CommentRemoved(:final commentId):
        _removeComment(commentId);
    }
  }

  void _addIncomingComment(Comment comment) {
    if (comment.postId != state.postId || _isDisplayed(comment.id)) {
      return;
    }
    emit(_withAddedComment(comment));
  }

  void _removeComment(String commentId) {
    if (!_isDisplayed(commentId)) {
      return;
    }
    final post = state.post;
    emit(
      state.copyWith(
        comments: state.comments
            .where((comment) => comment.id != commentId)
            .toList(),
        post: () =>
            post?.copyWith(commentsCount: math.max(0, post.commentsCount - 1)),
        highlightedCommentId: state.highlightedCommentId == commentId
            ? () => null
            : null,
      ),
    );
  }

  bool _isDisplayed(String commentId) {
    return state.comments.any((comment) => comment.id == commentId);
  }

  PostDetailState _withAddedComment(Comment comment) {
    final post = state.post;
    return state.copyWith(
      comments: [...state.comments, comment],
      post: () => post?.copyWith(commentsCount: post.commentsCount + 1),
    );
  }
}
