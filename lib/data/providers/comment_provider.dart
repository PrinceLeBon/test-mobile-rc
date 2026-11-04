import 'dart:async';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/comment.dart';
import '../models/comment_event.dart';
import '../models/post.dart';

class CommentProvider {
  Future<List<Comment>> fetchForPost(
    String postId, {
    required int limit,
  }) async {
    final query =
        QueryBuilder<ParseObject>(ParseObject(CommentFields.className))
          ..whereEqualTo(CommentFields.post, _postPointer(postId))
          ..orderByAscending(CommentFields.createdAt)
          ..setLimit(limit)
          ..includeObject([CommentFields.author]);

    final response = await query.query<ParseObject>();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
    final results = response.results ?? const <dynamic>[];
    return results
        .whereType<ParseObject>()
        .map((object) => _toComment(object, postId: postId))
        .toList();
  }

  Future<Comment> create({required String postId, required String text}) async {
    final object = ParseObject(CommentFields.className)
      ..set(CommentFields.post, _postPointer(postId).toPointer())
      ..set(CommentFields.text, text);

    final response = await object.save();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    return _toComment(object, postId: postId, fallbackAuthor: currentUser);
  }

  Stream<CommentEvent> watchForPost(String postId) {
    final client = LiveQuery().client;
    Subscription<ParseObject>? subscription;
    var isCancelled = false;
    late final StreamController<CommentEvent> controller;

    Future<void> subscribe() async {
      final query = QueryBuilder<ParseObject>(
        ParseObject(CommentFields.className),
      )..whereEqualTo(CommentFields.post, _postPointer(postId));
      final created = await client.subscribe<ParseObject>(query);
      if (isCancelled) {
        client.unSubscribe(created);
        return;
      }
      subscription = created;
      created.on(LiveQueryEvent.create, (ParseObject object) async {
        final comment = await _withAuthor(object, postId: postId);
        if (!isCancelled) {
          controller.add(CommentAdded(comment));
        }
      });
      created.on(LiveQueryEvent.delete, (ParseObject object) {
        final commentId = object.objectId;
        if (!isCancelled && commentId != null) {
          controller.add(CommentRemoved(commentId));
        }
      });
    }

    controller = StreamController<CommentEvent>(
      onListen: () {
        subscribe().catchError(controller.addError);
      },
      onCancel: () {
        isCancelled = true;
        final active = subscription;
        subscription = null;
        if (active != null) {
          client.unSubscribe(active);
        }
      },
    );
    return controller.stream;
  }

  Future<Comment> _withAuthor(
    ParseObject liveObject, {
    required String postId,
  }) async {
    final commentId = liveObject.objectId;
    if (commentId != null) {
      final query =
          QueryBuilder<ParseObject>(ParseObject(CommentFields.className))
            ..whereEqualTo(CommentFields.objectId, commentId)
            ..includeObject([CommentFields.author]);
      final response = await query.query<ParseObject>();
      final results = response.results ?? const <dynamic>[];
      final fetched = results.whereType<ParseObject>().firstOrNull;
      if (response.success && fetched != null) {
        return _toComment(fetched, postId: postId);
      }
    }
    return _toComment(liveObject, postId: postId);
  }

  ParseObject _postPointer(String postId) {
    return ParseObject(PostFields.className)..objectId = postId;
  }

  Comment _toComment(
    ParseObject object, {
    required String postId,
    ParseUser? fallbackAuthor,
  }) {
    final author = object.get<ParseObject>(CommentFields.author);
    final authorName =
        author?.get<String>(CommentFields.authorUsername) ??
        fallbackAuthor?.username ??
        Comment.unknownAuthorName;
    return Comment(
      id: object.objectId ?? '',
      postId: postId,
      text: object.get<String>(CommentFields.text) ?? '',
      authorId: author?.objectId ?? fallbackAuthor?.objectId ?? '',
      authorName: authorName,
      createdAt: object.createdAt ?? DateTime.now(),
    );
  }
}
