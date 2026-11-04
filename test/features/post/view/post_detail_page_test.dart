import 'package:blog_app/app.dart';
import 'package:blog_app/core/constants/validation_rules.dart';
import 'package:blog_app/data/models/comment.dart';
import 'package:blog_app/data/models/comment_event.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/data/repositories/comment_repository.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/feed/view/post_card.dart';
import 'package:blog_app/features/post/view/post_detail_texts.dart';
import 'package:blog_app/shared/widgets/post_stat_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/fake_auth_provider.dart';
import '../../../helpers/fake_comment_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  final post = samplePost(4);

  Future<(FakePostProvider, FakeCommentProvider)> openDetailSignedIn(
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final authProvider = FakeAuthProvider()..onCurrentUser = () async => alice;
    final postProvider = FakePostProvider(posts: [post]);
    final commentProvider = FakeCommentProvider(
      comments: [sampleComment(1, postId: post.id)],
    );
    await tester.pumpWidget(
      BlogApp(
        authRepository: AuthRepository(authProvider),
        postRepository: PostRepository(postProvider),
        commentRepository: CommentRepository(commentProvider),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PostCard));
    await tester.pumpAndSettle();
    return (postProvider, commentProvider);
  }

  Finder commentCountChip(int count) => find.byWidgetPredicate(
    (widget) => widget is CommentCountChip && widget.count == count,
  );

  IconButton sendButton(WidgetTester tester) => tester.widget<IconButton>(
    find.ancestor(
      of: find.byIcon(Icons.send_rounded),
      matching: find.byType(IconButton),
    ),
  );

  testWidgets(
    'un commentaire envoyé apparaît, vide le champ et met à jour la carte',
    (tester) async {
      final (postProvider, commentProvider) = await openDetailSignedIn(tester);

      expect(find.text('Commentaire 1'), findsOneWidget);
      expect(commentCountChip(post.commentsCount), findsOneWidget);

      await tester.enterText(find.byType(TextField), '  Super article  ');
      await tester.pump();
      await tester.tap(find.byTooltip(PostDetailTexts.send));
      await tester.pumpAndSettle();

      expect(commentProvider.createCalls, [(post.id, 'Super article')]);
      expect(find.text('Super article'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
      expect(commentCountChip(post.commentsCount + 1), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(commentCountChip(post.commentsCount + 1), findsOneWidget);
      expect(postProvider.fetchPageCalls, hasLength(1));
    },
  );

  testWidgets(
    'un commentaire reçu en direct apparaît et l’abonnement s’arrête au retour',
    (tester) async {
      final (_, commentProvider) = await openDetailSignedIn(tester);

      expect(commentProvider.watchCalls, [post.id]);
      expect(commentProvider.hasLiveListener, isTrue);

      commentProvider.emitLive(
        CommentAdded(
          Comment(
            id: 'live-1',
            postId: post.id,
            text: 'Arrivé en direct',
            authorId: 'u3',
            authorName: 'carol',
            createdAt: DateTime.utc(2026, 11, 4, 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Arrivé en direct'), findsOneWidget);
      expect(commentCountChip(post.commentsCount + 1), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(commentProvider.hasLiveListener, isFalse);
      expect(commentCountChip(post.commentsCount + 1), findsOneWidget);
    },
  );

  testWidgets('l’envoi suit les bornes du serveur sur le texte nettoyé', (
    tester,
  ) async {
    await openDetailSignedIn(tester);
    final longest = 'a' * ValidationRules.commentMaxLength;

    expect(sendButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '    ');
    await tester.pump();
    expect(sendButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), ' $longest ');
    await tester.pumpAndSettle();
    expect(sendButton(tester).onPressed, isNotNull);
    expect(find.text('500/500'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '${longest}a');
    await tester.pumpAndSettle();
    expect(sendButton(tester).onPressed, isNull);
    expect(find.text('501/500'), findsOneWidget);
  });
}
