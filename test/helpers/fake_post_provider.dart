import 'package:blog_app/data/models/post.dart';
import 'package:blog_app/data/providers/post_provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Post samplePost(int index) {
  return Post(
    id: 'post-$index',
    title: 'Article $index',
    body: 'Contenu de l’article $index',
    authorId: 'u1',
    authorName: 'alice',
    createdAt: DateTime.utc(
      2026,
      11,
      4,
      0,
      0,
      0,
    ).subtract(Duration(minutes: index)),
    likesCount: index % 4,
    commentsCount: index % 3,
  );
}

List<Post> samplePosts(int count) => List.generate(count, samplePost);

class FakePostProvider implements PostProvider {
  FakePostProvider({List<Post>? posts}) : posts = posts ?? const [];

  List<Post> posts;
  Future<List<Post>> Function(int skip, int limit)? onFetchPage;
  final List<(int, int)> fetchPageCalls = [];
  Future<Post> Function(String postId)? onFetchById;
  final List<String> fetchByIdCalls = [];
  Future<Post> Function(String title, String body)? onCreate;
  final List<(String, String)> createCalls = [];
  Future<void> Function(String postId)? onDelete;
  final List<String> deleteCalls = [];

  @override
  Future<List<Post>> fetchPage({required int skip, required int limit}) {
    fetchPageCalls.add((skip, limit));
    final handler = onFetchPage;
    if (handler != null) {
      return handler(skip, limit);
    }
    return Future.value(posts.skip(skip).take(limit).toList());
  }

  @override
  Future<Post> fetchById(String postId) {
    fetchByIdCalls.add(postId);
    final handler = onFetchById;
    if (handler != null) {
      return handler(postId);
    }
    for (final post in posts) {
      if (post.id == postId) {
        return Future.value(post);
      }
    }
    return Future.error(ParseError(code: ParseError.objectNotFound));
  }

  @override
  Future<Post> create({required String title, required String body}) {
    createCalls.add((title, body));
    final handler = onCreate;
    if (handler != null) {
      return handler(title, body);
    }
    final post = Post(
      id: 'created-${createCalls.length}',
      title: title,
      body: body,
      authorId: 'u1',
      authorName: 'alice',
      createdAt: DateTime.utc(2026, 11, 4, 1),
    );
    posts = [post, ...posts];
    return Future.value(post);
  }

  @override
  Future<void> delete(String postId) {
    deleteCalls.add(postId);
    final handler = onDelete;
    if (handler != null) {
      return handler(postId);
    }
    posts = posts.where((post) => post.id != postId).toList();
    return Future.value();
  }
}
