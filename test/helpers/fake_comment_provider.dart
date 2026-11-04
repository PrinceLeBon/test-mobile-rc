import 'dart:async';

import 'package:blog_app/data/models/comment.dart';
import 'package:blog_app/data/models/comment_event.dart';
import 'package:blog_app/data/providers/comment_provider.dart';

Comment sampleComment(int index, {String postId = 'post-1'}) {
  return Comment(
    id: 'comment-$index',
    postId: postId,
    text: 'Commentaire $index',
    authorId: 'u2',
    authorName: 'bob',
    createdAt: DateTime.utc(2026, 11, 4).add(Duration(minutes: index)),
  );
}

class FakeCommentProvider implements CommentProvider {
  FakeCommentProvider({List<Comment>? comments})
    : comments = comments ?? const [];

  List<Comment> comments;
  Future<List<Comment>> Function(String postId, int limit)? onFetchForPost;
  Future<Comment> Function(String postId, String text)? onCreate;
  final List<(String, int)> fetchCalls = [];
  final List<(String, String)> createCalls = [];
  final List<String> watchCalls = [];
  final StreamController<CommentEvent> liveEvents =
      StreamController<CommentEvent>.broadcast();

  bool get hasLiveListener => liveEvents.hasListener;

  void emitLive(CommentEvent event) => liveEvents.add(event);

  @override
  Stream<CommentEvent> watchForPost(String postId) {
    watchCalls.add(postId);
    return liveEvents.stream;
  }

  @override
  Future<List<Comment>> fetchForPost(String postId, {required int limit}) {
    fetchCalls.add((postId, limit));
    final handler = onFetchForPost;
    if (handler != null) {
      return handler(postId, limit);
    }
    return Future.value(comments);
  }

  @override
  Future<Comment> create({required String postId, required String text}) {
    createCalls.add((postId, text));
    final handler = onCreate;
    if (handler != null) {
      return handler(postId, text);
    }
    return Future.value(
      Comment(
        id: 'created-${createCalls.length}',
        postId: postId,
        text: text,
        authorId: 'u1',
        authorName: 'alice',
        createdAt: DateTime.utc(2026, 11, 4, 1),
      ),
    );
  }
}
