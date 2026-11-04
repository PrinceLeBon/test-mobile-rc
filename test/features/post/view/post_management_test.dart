import 'package:blog_app/app.dart';
import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/data/repositories/comment_repository.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/auth/cubit/auth_cubit.dart';
import 'package:blog_app/features/auth/cubit/auth_state.dart';
import 'package:blog_app/features/feed/view/post_card.dart';
import 'package:blog_app/features/feed/view/write_post_button.dart';
import 'package:blog_app/features/post/view/new_post_page.dart';
import 'package:blog_app/features/post/view/post_detail_page.dart';
import 'package:blog_app/features/post/view/post_detail_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/fake_auth_provider.dart';
import '../../../helpers/fake_comment_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  const bob = AppUser(id: 'u2', username: 'bob');
  final alicePost = samplePost(4);

  Future<FakePostProvider> pumpApp(WidgetTester tester, {AppUser? user}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final authProvider = FakeAuthProvider()
      ..onCurrentUser = (() async => user)
      ..onFetchCurrentUser = (() async => user ?? alice);
    final postProvider = FakePostProvider(posts: [alicePost]);
    await tester.pumpWidget(
      BlogApp(
        authRepository: AuthRepository(authProvider),
        postRepository: PostRepository(postProvider),
        commentRepository: CommentRepository(FakeCommentProvider()),
      ),
    );
    await tester.pumpAndSettle();
    return postProvider;
  }

  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(find.byType(PostCard));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsOneWidget);
  }

  AuthState authStateOn(WidgetTester tester, Type pageType) =>
      tester.element(find.byType(pageType)).read<AuthCubit>().state;

  Finder titleField() => find.byType(TextField).at(0);
  Finder bodyField() => find.byType(TextField).at(1);

  group('création', () {
    testWidgets('publie un article nettoyé et le place en tête du fil', (
      tester,
    ) async {
      final postProvider = await pumpApp(tester, user: alice);

      await tester.tap(find.byType(WritePostButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewPostPage), findsOneWidget);

      await tester.tap(find.text(NewPostPage.submitLabel));
      await tester.pumpAndSettle();
      expect(
        find.text('Le titre doit contenir au moins 3 caractères.'),
        findsOneWidget,
      );
      expect(find.text('Le contenu est obligatoire.'), findsOneWidget);
      expect(postProvider.createCalls, isEmpty);

      await tester.enterText(titleField(), '  Neuf  ');
      await tester.enterText(bodyField(), ' Texte ');
      await tester.pump();
      expect(find.text('4/120'), findsOneWidget);
      expect(find.text('5/5000'), findsOneWidget);

      await tester.tap(find.text(NewPostPage.submitLabel));
      await tester.pumpAndSettle();

      expect(postProvider.createCalls, [('Neuf', 'Texte')]);
      expect(find.byType(NewPostPage), findsNothing);
      expect(find.text(NewPostPage.publishedMessage), findsOneWidget);
      final firstCard = tester.widget<PostCard>(find.byType(PostCard).first);
      expect(firstCard.post.title, 'Neuf');
    });

    testWidgets('une erreur serveur reste affichée sur l’écran', (
      tester,
    ) async {
      final postProvider = await pumpApp(tester, user: alice);
      postProvider.onCreate = (title, body) => Future.error(parseError(142));

      await tester.tap(find.byType(WritePostButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField(), 'Titre');
      await tester.enterText(bodyField(), 'Texte');
      await tester.tap(find.text(NewPostPage.submitLabel));
      await tester.pumpAndSettle();

      expect(find.byType(NewPostPage), findsOneWidget);
      expect(find.text('serveur'), findsOneWidget);
    });
  });

  testWidgets('une session expirée à la publication déconnecte', (
    tester,
  ) async {
    final postProvider = await pumpApp(tester, user: alice);
    postProvider.onCreate = (title, body) => Future.error(parseError(209));

    await tester.tap(find.byType(WritePostButton));
    await tester.pumpAndSettle();
    expect(authStateOn(tester, NewPostPage), isA<AuthAuthenticated>());
    await tester.enterText(titleField(), 'Titre');
    await tester.enterText(bodyField(), 'Texte');
    await tester.tap(find.text(NewPostPage.submitLabel));
    await tester.pumpAndSettle();

    expect(postProvider.createCalls, [('Titre', 'Texte')]);
    expect(authStateOn(tester, NewPostPage), isA<AuthUnauthenticated>());
  });

  group('suppression', () {
    testWidgets('seul l’auteur voit le bouton supprimer', (tester) async {
      await pumpApp(tester, user: alice);
      await openDetail(tester);
      expect(find.byTooltip(PostDetailTexts.deleteTooltip), findsOneWidget);
    });

    testWidgets('un autre utilisateur ne voit pas le bouton', (tester) async {
      await pumpApp(tester, user: bob);
      await openDetail(tester);
      expect(find.byTooltip(PostDetailTexts.deleteTooltip), findsNothing);
    });

    testWidgets('un visiteur ne voit pas le bouton', (tester) async {
      await pumpApp(tester);
      await openDetail(tester);
      expect(find.byTooltip(PostDetailTexts.deleteTooltip), findsNothing);
    });

    testWidgets('confirmer supprime l’article et revient au fil', (
      tester,
    ) async {
      final postProvider = await pumpApp(tester, user: alice);
      await openDetail(tester);

      await tester.tap(find.byTooltip(PostDetailTexts.deleteTooltip));
      await tester.pumpAndSettle();
      expect(find.text(PostDetailTexts.deleteDialogTitle), findsOneWidget);
      expect(find.text(PostDetailTexts.deleteDialogMessage), findsOneWidget);

      await tester.tap(find.text(PostDetailTexts.deleteConfirm));
      await tester.pumpAndSettle();

      expect(postProvider.deleteCalls, [alicePost.id]);
      expect(find.byType(PostDetailPage), findsNothing);
      expect(find.byType(PostCard), findsNothing);
      expect(find.text(PostDetailTexts.deletedMessage), findsOneWidget);
    });

    testWidgets('annuler garde l’article', (tester) async {
      final postProvider = await pumpApp(tester, user: alice);
      await openDetail(tester);

      await tester.tap(find.byTooltip(PostDetailTexts.deleteTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PostDetailTexts.deleteCancel));
      await tester.pumpAndSettle();

      expect(postProvider.deleteCalls, isEmpty);
      expect(find.byType(PostDetailPage), findsOneWidget);
    });

    testWidgets('un échec de suppression s’affiche sans quitter l’écran', (
      tester,
    ) async {
      final postProvider = await pumpApp(tester, user: alice);
      postProvider.onDelete = (postId) => Future.error(parseError(101));
      await openDetail(tester);

      await tester.tap(find.byTooltip(PostDetailTexts.deleteTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PostDetailTexts.deleteConfirm));
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailPage), findsOneWidget);
      expect(find.text(PostDetailTexts.deleteDialogTitle), findsNothing);
      expect(
        find.text('Cet article n’existe plus ou vous n’y avez pas accès.'),
        findsOneWidget,
      );
    });

    testWidgets('une session expirée à la suppression déconnecte', (
      tester,
    ) async {
      final postProvider = await pumpApp(tester, user: alice);
      postProvider.onDelete = (postId) => Future.error(parseError(209));
      await openDetail(tester);
      expect(authStateOn(tester, PostDetailPage), isA<AuthAuthenticated>());

      await tester.tap(find.byTooltip(PostDetailTexts.deleteTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PostDetailTexts.deleteConfirm));
      await tester.pumpAndSettle();

      expect(postProvider.deleteCalls, [alicePost.id]);
      expect(authStateOn(tester, PostDetailPage), isA<AuthUnauthenticated>());
      expect(find.byTooltip(PostDetailTexts.deleteTooltip), findsNothing);
    });
  });
}
