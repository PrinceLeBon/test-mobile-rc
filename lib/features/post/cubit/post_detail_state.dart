import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/post.dart';

enum PostDetailStatus { loading, success, failure }

enum CommentsStatus { loading, success, failure }

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.postId,
    this.post,
    this.postStatus = PostDetailStatus.loading,
    this.postFailure,
    this.comments = const [],
    this.commentsStatus = CommentsStatus.loading,
    this.commentsFailure,
    this.isSendingComment = false,
    this.sendFailure,
    this.highlightedCommentId,
    this.isDeleting = false,
    this.deleteFailure,
  });

  final String postId;
  final Post? post;
  final PostDetailStatus postStatus;
  final Failure? postFailure;
  final List<Comment> comments;
  final CommentsStatus commentsStatus;
  final Failure? commentsFailure;
  final bool isSendingComment;
  final Failure? sendFailure;
  final String? highlightedCommentId;
  final bool isDeleting;
  final Failure? deleteFailure;

  bool get hasSessionFailure =>
      postFailure is SessionFailure ||
      commentsFailure is SessionFailure ||
      sendFailure is SessionFailure ||
      deleteFailure is SessionFailure;

  PostDetailState copyWith({
    Post? Function()? post,
    PostDetailStatus? postStatus,
    Failure? Function()? postFailure,
    List<Comment>? comments,
    CommentsStatus? commentsStatus,
    Failure? Function()? commentsFailure,
    bool? isSendingComment,
    Failure? Function()? sendFailure,
    String? Function()? highlightedCommentId,
    bool? isDeleting,
    Failure? Function()? deleteFailure,
  }) {
    return PostDetailState(
      postId: postId,
      post: post == null ? this.post : post(),
      postStatus: postStatus ?? this.postStatus,
      postFailure: postFailure == null ? this.postFailure : postFailure(),
      comments: comments ?? this.comments,
      commentsStatus: commentsStatus ?? this.commentsStatus,
      commentsFailure: commentsFailure == null
          ? this.commentsFailure
          : commentsFailure(),
      isSendingComment: isSendingComment ?? this.isSendingComment,
      sendFailure: sendFailure == null ? this.sendFailure : sendFailure(),
      highlightedCommentId: highlightedCommentId == null
          ? this.highlightedCommentId
          : highlightedCommentId(),
      isDeleting: isDeleting ?? this.isDeleting,
      deleteFailure: deleteFailure == null
          ? this.deleteFailure
          : deleteFailure(),
    );
  }

  @override
  List<Object?> get props => [
    postId,
    post,
    postStatus,
    postFailure,
    comments,
    commentsStatus,
    commentsFailure,
    isSendingComment,
    sendFailure,
    highlightedCommentId,
    isDeleting,
    deleteFailure,
  ];
}
