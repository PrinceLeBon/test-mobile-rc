import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/comment_provider.dart';
import 'data/providers/like_provider.dart';
import 'data/providers/post_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/comment_repository.dart';
import 'data/repositories/like_repository.dart';
import 'data/repositories/post_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/feed/cubit/feed_cubit.dart';
import 'features/likes/cubit/likes_cubit.dart';
import 'features/likes/view/likes_sync.dart';

class BlogApp extends StatefulWidget {
  const BlogApp({
    super.key,
    this.authRepository,
    this.postRepository,
    this.commentRepository,
    this.likeRepository,
  });

  static const String title = 'Blog';
  static const Locale locale = Locale('fr', 'FR');

  final AuthRepository? authRepository;
  final PostRepository? postRepository;
  final CommentRepository? commentRepository;
  final LikeRepository? likeRepository;

  @override
  State<BlogApp> createState() => _BlogAppState();
}

class _BlogAppState extends State<BlogApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) =>
              widget.authRepository ?? AuthRepository(AuthProvider()),
        ),
        RepositoryProvider<PostRepository>(
          create: (_) =>
              widget.postRepository ?? PostRepository(PostProvider()),
        ),
        RepositoryProvider<CommentRepository>(
          create: (_) =>
              widget.commentRepository ?? CommentRepository(CommentProvider()),
        ),
        RepositoryProvider<LikeRepository>(
          create: (_) =>
              widget.likeRepository ?? LikeRepository(LikeProvider()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..restoreSession(),
          ),
          BlocProvider<FeedCubit>(
            create: (context) =>
                FeedCubit(context.read<PostRepository>())..loadInitial(),
          ),
          BlocProvider<LikesCubit>(
            create: (context) => LikesCubit(context.read<LikeRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: BlogApp.title,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: BlogApp.locale,
          supportedLocales: const [BlogApp.locale],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
          builder: (_, child) => LikesSync(child: child ?? const SizedBox()),
        ),
      ),
    );
  }
}
