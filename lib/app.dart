import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class BlogApp extends StatefulWidget {
  const BlogApp({super.key});

  static const String title = 'Blog';
  static const Locale locale = Locale('fr', 'FR');

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
    return MaterialApp.router(
      title: BlogApp.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: BlogApp.locale,
      supportedLocales: const [BlogApp.locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router,
    );
  }
}
