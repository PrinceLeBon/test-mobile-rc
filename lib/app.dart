import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';

class BlogApp extends StatefulWidget {
  const BlogApp({super.key, this.authRepository});

  static const String title = 'Blog';
  static const Locale locale = Locale('fr', 'FR');

  final AuthRepository? authRepository;

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
    return RepositoryProvider<AuthRepository>(
      create: (_) => widget.authRepository ?? AuthRepository(AuthProvider()),
      child: BlocProvider<AuthCubit>(
        create: (context) =>
            AuthCubit(context.read<AuthRepository>())..restoreSession(),
        child: MaterialApp.router(
          title: BlogApp.title,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: BlogApp.locale,
          supportedLocales: const [BlogApp.locale],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
