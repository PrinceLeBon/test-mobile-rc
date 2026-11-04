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
}
