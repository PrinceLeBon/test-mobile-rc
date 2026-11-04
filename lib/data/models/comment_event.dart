import 'package:equatable/equatable.dart';

import 'comment.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();
}

final class CommentAdded extends CommentEvent {
  const CommentAdded(this.comment);

  final Comment comment;

  @override
  List<Object?> get props => [comment];
}

final class CommentRemoved extends CommentEvent {
  const CommentRemoved(this.commentId);

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}
