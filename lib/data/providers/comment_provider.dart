import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/comment.dart';
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
      ..set(CommentFields.post, _postPointer(postId))
      ..set(CommentFields.text, text);

    final response = await object.save();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    return _toComment(object, postId: postId, fallbackAuthor: currentUser);
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
