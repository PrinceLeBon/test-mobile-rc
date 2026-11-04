abstract final class AppRoutes {
  static const String feed = '/feed';
  static const String login = '/login';
  static const String register = '/register';
  static const String newPost = '/posts/new';
  static const String postDetailPattern = '/posts/:id';
  static const String postIdParameter = 'id';

  static String postDetail(String postId) => '/posts/$postId';
}
