import 'package:blog_app/app.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/data/repositories/comment_repository.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/auth/view/login_page.dart';
import 'package:blog_app/features/feed/view/feed_body.dart';
import 'package:blog_app/features/feed/view/post_card.dart';
import 'package:blog_app/features/feed/view/write_post_button.dart';
import 'package:blog_app/features/post/view/post_detail_page.dart';
import 'package:blog_app/features/post/view/post_detail_texts.dart';
import 'package:blog_app/shared/widgets/post_stat_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_auth_provider.dart';
import '../../../helpers/fake_comment_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Future<FakePostProvider> pumpFeed(
    WidgetTester tester, {
    List<int>? postIndexes,
    FakePostProvider? postProvider,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final provider =
        postProvider ??
        FakePostProvider(
          posts: (postIndexes ?? const []).map(samplePost).toList(),
        );
    await tester.pumpWidget(
      BlogApp(
        authRepository: AuthRepository(FakeAuthProvider()),
        postRepository: PostRepository(provider),
        commentRepository: CommentRepository(
          FakeCommentProvider(comments: [sampleComment(1, postId: 'post-4')]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('la carte montre auteur, titre, extrait et compteurs', (
    tester,
  ) async {
    await pumpFeed(tester, postIndexes: [7]);

    final card = find.byType(PostCard);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.text('Article 7')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('alice')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('Contenu de l’article 7')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(LikeChip), matching: find.text('3')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CommentCountChip),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('une liste courte se termine par la fin du fil', (tester) async {
    await pumpFeed(tester, postIndexes: [1, 2]);

    expect(find.byType(PostCard), findsNWidgets(2));
    expect(find.text(FeedTexts.endOfFeed), findsOneWidget);
  });

  testWidgets('le fil vide invite le visiteur à se connecter', (tester) async {
    await pumpFeed(tester);

    expect(find.text(FeedTexts.emptyTitle), findsOneWidget);
    expect(find.text(FeedTexts.emptyMessage), findsOneWidget);
    expect(find.text(FeedTexts.signIn), findsNWidgets(2));
  });

  testWidgets('l’erreur de chargement propose de réessayer', (tester) async {
    final provider = FakePostProvider(posts: [samplePost(1)])
      ..onFetchPage = (skip, limit) => Future.error(
        ParseError(code: ParseError.connectionFailed, message: 'réseau'),
      );
    await pumpFeed(tester, postProvider: provider);

    expect(find.text(FeedTexts.loadErrorTitle), findsOneWidget);

    provider.onFetchPage = null;
    await tester.tap(find.text(FeedTexts.retry));
    await tester.pumpAndSettle();

    expect(find.text('Article 1'), findsOneWidget);
    expect(provider.fetchPageCalls, hasLength(2));
  });

  testWidgets('toucher une carte ouvre le détail de l’article', (tester) async {
    await pumpFeed(tester, postIndexes: [4]);

    await tester.tap(find.byType(PostCard));
    await tester.pumpAndSettle();

    final detail = tester.widget<PostDetailPage>(find.byType(PostDetailPage));
    expect(detail.postId, 'post-4');
    expect(detail.initialPost, samplePost(4));
    expect(find.text(samplePost(4).body), findsOneWidget);
    expect(find.text('Commentaire 1'), findsOneWidget);
    expect(find.text(PostDetailTexts.visitorInvite), findsOneWidget);
  });

  testWidgets('le bouton Écrire envoie le visiteur vers la connexion', (
    tester,
  ) async {
    await pumpFeed(tester, postIndexes: [1]);

    await tester.tap(find.byType(WritePostButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
