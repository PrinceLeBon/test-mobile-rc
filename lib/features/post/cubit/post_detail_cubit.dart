import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/validation_rules.dart';
import '../../../core/error/failure.dart';
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
        final post = state.post;
        emit(
          state.copyWith(
            isSendingComment: false,
            comments: [...state.comments, comment],
            highlightedCommentId: () => comment.id,
            post: () => post?.copyWith(commentsCount: post.commentsCount + 1),
          ),
        );
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
}
