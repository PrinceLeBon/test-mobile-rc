import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/like_result.dart';
import '../models/post.dart';

class LikeProvider {
  Future<LikeResult> toggle(String postId) async {
    final response = await ParseCloudFunction(
      LikeFields.toggleFunction,
    ).execute(parameters: {LikeFields.postIdParameter: postId});
    final result = response.result;
    if (!response.success || result is! Map) {
      throw response.error ?? ParseError();
    }
    return LikeResult.fromJson(Map<String, dynamic>.from(result));
  }

  Future<Set<String>> fetchLikedPostIds(List<String> postIds) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null ||
        currentUser.objectId == null ||
        postIds.isEmpty) {
      return const <String>{};
    }
    final postPointers = postIds
        .map(
          (id) =>
              (ParseObject(PostFields.className)..objectId = id).toPointer(),
        )
        .toList();
    final query = QueryBuilder<ParseObject>(ParseObject(LikeFields.className))
      ..whereEqualTo(LikeFields.user, currentUser.toPointer())
      ..whereContainedIn(LikeFields.post, postPointers)
      ..setLimit(postIds.length);

    final response = await query.query<ParseObject>();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
    final results = response.results ?? const <dynamic>[];
    return results
        .whereType<ParseObject>()
        .map((like) => like.get<ParseObject>(LikeFields.post)?.objectId)
        .whereType<String>()
        .toSet();
  }
}
