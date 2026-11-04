import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/post.dart';

class PostProvider {
  Future<List<Post>> fetchPage({required int skip, required int limit}) async {
    final query = QueryBuilder<ParseObject>(ParseObject(PostFields.className))
      ..orderByDescending(PostFields.createdAt)
      ..setAmountToSkip(skip)
      ..setLimit(limit)
      ..includeObject([PostFields.author]);

    final response = await query.query<ParseObject>();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
    final results = response.results ?? const <dynamic>[];
    return results.whereType<ParseObject>().map(Post.fromParseObject).toList();
  }

  Future<Post> fetchById(String postId) async {
    final response = await ParseObject(
      PostFields.className,
    ).getObject(postId, include: [PostFields.author]);
    final result = response.result;
    if (!response.success || result is! ParseObject) {
      throw response.error ?? ParseError(code: ParseError.objectNotFound);
    }
    return Post.fromParseObject(result);
  }

  Future<Post> create({required String title, required String body}) async {
    final object = ParseObject(PostFields.className)
      ..set(PostFields.title, title)
      ..set(PostFields.body, body);

    final response = await object.save();
    final postId = object.objectId;
    if (!response.success || postId == null) {
      throw response.error ?? ParseError();
    }
    return fetchById(postId);
  }

  Future<void> delete(String postId) async {
    final response = await (ParseObject(
      PostFields.className,
    )..objectId = postId).delete();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
  }
}
