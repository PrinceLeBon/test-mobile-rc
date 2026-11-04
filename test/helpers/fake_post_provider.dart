import 'package:blog_app/data/models/post.dart';
import 'package:blog_app/data/providers/post_provider.dart';

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

  @override
  Future<List<Post>> fetchPage({required int skip, required int limit}) {
    fetchPageCalls.add((skip, limit));
    final handler = onFetchPage;
    if (handler != null) {
      return handler(skip, limit);
    }
    return Future.value(posts.skip(skip).take(limit).toList());
  }
}
