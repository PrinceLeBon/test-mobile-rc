import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/register_page.dart';
import '../../features/feed/view/feed_page.dart';
import '../../features/post/view/new_post_page.dart';
import '../../features/post/view/post_detail_page.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: AppRoutes.feed,
      routes: [
        GoRoute(path: '/', redirect: (context, state) => AppRoutes.feed),
        GoRoute(
          path: AppRoutes.feed,
          builder: (context, state) => const FeedPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.newPost,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const NewPostPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.postDetailPattern,
          builder: (context, state) => PostDetailPage(
            postId: state.pathParameters[AppRoutes.postIdParameter] ?? '',
          ),
        ),
      ],
    );
  }
}
