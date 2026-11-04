import 'dart:async';

import 'package:blog_app/core/constants/validation_rules.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/data/models/comment.dart';
import 'package:blog_app/data/models/comment_event.dart';
import 'package:blog_app/data/models/post.dart';
import 'package:blog_app/data/repositories/comment_repository.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/post/cubit/post_detail_cubit.dart';
import 'package:blog_app/features/post/cubit/post_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_comment_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  final displayedPost = samplePost(1);
  final freshPost = displayedPost.copyWith(likesCount: 9, commentsCount: 2);
  final storedComments = [sampleComment(1), sampleComment(2)];

  late FakePostProvider postProvider;
  late FakeCommentProvider commentProvider;

  setUp(() {
    postProvider = FakePostProvider(posts: [freshPost]);
    commentProvider = FakeCommentProvider(comments: storedComments);
  });

  PostDetailCubit buildCubit({Post? initialPost}) {
    return PostDetailCubit(
      postRepository: PostRepository(postProvider),
      commentRepository: CommentRepository(commentProvider),
      postId: displayedPost.id,
      initialPost: initialPost,
    );
  }

  Future<PostDetailCubit> loadedCubit() async {
    final cubit = buildCubit(initialPost: displayedPost);
    addTearDown(cubit.close);
    await cubit.load();
    return cubit;
  }

  group('chargement', () {
    test('le post du fil s’affiche avant le rechargement', () {
      final cubit = buildCubit(initialPost: displayedPost);
      addTearDown(cubit.close);

      expect(cubit.state.post, displayedPost);
      expect(cubit.state.postStatus, PostDetailStatus.success);
      expect(cubit.state.commentsStatus, CommentsStatus.loading);
    });

    test(
      'le rechargement remplace le post et charge les commentaires',
      () async {
        final cubit = await loadedCubit();

        expect(postProvider.fetchByIdCalls, [displayedPost.id]);
        expect(commentProvider.fetchCalls, [
          (displayedPost.id, CommentRepository.maxCommentsPerPost),
        ]);
        expect(cubit.state.post, freshPost);
        expect(cubit.state.comments, storedComments);
        expect(cubit.state.commentsStatus, CommentsStatus.success);
      },
    );

    test('sans post du fil, la page charge puis affiche le post', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.post, isNull);
      expect(cubit.state.postStatus, PostDetailStatus.loading);

      await cubit.load();

      expect(cubit.state.post, freshPost);
      expect(cubit.state.postStatus, PostDetailStatus.success);
    });

    test('un article supprimé donne l’état introuvable', () async {
      postProvider.posts = const [];
      final cubit = await loadedCubit();

      expect(cubit.state.post, isNull);
      expect(cubit.state.postStatus, PostDetailStatus.failure);
      expect(cubit.state.postFailure, const NotFoundFailure());
      expect(cubit.state.postFailure?.message, FailureMessages.notFound);
    });

    test('une panne réseau garde le post déjà affiché', () async {
      postProvider.onFetchById = (_) =>
          Future.error(ParseError(code: ParseError.connectionFailed));
      final cubit = await loadedCubit();

      expect(cubit.state.post, displayedPost);
      expect(cubit.state.postStatus, PostDetailStatus.success);
      expect(cubit.state.postFailure, const NetworkFailure());
    });

    test('les commentaires en erreur se rechargent avec Réessayer', () async {
      commentProvider.onFetchForPost = (_, _) =>
          Future.error(ParseError(code: ParseError.connectionFailed));
      final cubit = await loadedCubit();

      expect(cubit.state.commentsStatus, CommentsStatus.failure);
      expect(cubit.state.commentsFailure, const NetworkFailure());

      commentProvider.onFetchForPost = null;
      await cubit.loadComments();

      expect(cubit.state.commentsStatus, CommentsStatus.success);
      expect(cubit.state.commentsFailure, isNull);
      expect(cubit.state.comments, storedComments);
    });

    test('une session expirée est signalée', () async {
      commentProvider.onFetchForPost = (_, _) =>
          Future.error(ParseError(code: ParseError.invalidSessionToken));
      final cubit = await loadedCubit();

      expect(cubit.state.hasSessionFailure, isTrue);
    });
  });

  group('ajout de commentaire', () {
    test(
      'le commentaire nettoyé s’ajoute en fin de liste et le compteur monte',
      () async {
        final cubit = await loadedCubit();

        final sent = await cubit.addComment('  Bonne question  ');

        expect(sent, isTrue);
        expect(commentProvider.createCalls, [
          (displayedPost.id, 'Bonne question'),
        ]);
        expect(cubit.state.comments.length, storedComments.length + 1);
        expect(cubit.state.comments.last.text, 'Bonne question');
        expect(cubit.state.comments.last.authorName, 'alice');
        expect(cubit.state.highlightedCommentId, cubit.state.comments.last.id);
        expect(cubit.state.post?.commentsCount, freshPost.commentsCount + 1);
        expect(cubit.state.isSendingComment, isFalse);
      },
    );

    test('les bornes du serveur sont appliquées au texte nettoyé', () async {
      final cubit = await loadedCubit();
      final longest = 'a' * ValidationRules.commentMaxLength;

      expect(await cubit.addComment('   '), isFalse);
      expect(await cubit.addComment('${longest}a'), isFalse);
      expect(commentProvider.createCalls, isEmpty);

      expect(await cubit.addComment('  $longest  '), isTrue);
      expect(commentProvider.createCalls, [(displayedPost.id, longest)]);
    });

    test('un second envoi pendant la requête est ignoré', () async {
      final cubit = await loadedCubit();
      final pending = Completer<Comment>();
      commentProvider.onCreate = (_, _) => pending.future;

      final firstSend = cubit.addComment('Premier');
      expect(cubit.state.isSendingComment, isTrue);

      expect(await cubit.addComment('Second'), isFalse);
      expect(commentProvider.createCalls.length, 1);

      pending.complete(sampleComment(3));
      expect(await firstSend, isTrue);
      expect(cubit.state.isSendingComment, isFalse);

      commentProvider.onCreate = null;
      expect(await cubit.addComment('Second'), isTrue);
      expect(commentProvider.createCalls.length, 2);
    });

    test('un échec d’envoi garde la liste et expose l’erreur', () async {
      final cubit = await loadedCubit();
      commentProvider.onCreate = (_, _) => Future.error(
        ParseError(code: ParseError.validationError, message: 'text too long'),
      );

      final sent = await cubit.addComment('Texte');

      expect(sent, isFalse);
      expect(cubit.state.comments, storedComments);
      expect(cubit.state.post?.commentsCount, freshPost.commentsCount);
      expect(cubit.state.sendFailure, const ValidationFailure('text too long'));
      expect(cubit.state.isSendingComment, isFalse);
    });
  });

  group('commentaires en temps réel', () {
    Comment incomingComment(String id, {String? postId}) {
      return Comment(
        id: id,
        postId: postId ?? displayedPost.id,
        text: 'Arrivé en direct',
        authorId: 'u3',
        authorName: 'carol',
        createdAt: DateTime.utc(2026, 11, 4, 2),
      );
    }

    Future<void> deliverLiveEvents() => Future<void>.delayed(Duration.zero);

    Future<PostDetailCubit> watchingCubit() async {
      final cubit = await loadedCubit();
      cubit.watchComments();
      return cubit;
    }

    test(
      'un commentaire d’un autre utilisateur s’ajoute sans action',
      () async {
        final cubit = await watchingCubit();

        commentProvider.emitLive(CommentAdded(incomingComment('live-1')));
        await deliverLiveEvents();

        expect(commentProvider.watchCalls, [displayedPost.id]);
        expect(cubit.state.comments.map((comment) => comment.id), [
          ...storedComments.map((comment) => comment.id),
          'live-1',
        ]);
        expect(cubit.state.post?.commentsCount, freshPost.commentsCount + 1);
      },
    );

    test(
      'l’événement de mon propre commentaire ne crée pas de doublon',
      () async {
        final cubit = await watchingCubit();
        final sent = await cubit.addComment('Mon commentaire');
        final ownComment = cubit.state.comments.last;

        commentProvider.emitLive(CommentAdded(ownComment));
        await deliverLiveEvents();

        expect(sent, isTrue);
        expect(
          cubit.state.comments.where((comment) => comment.id == ownComment.id),
          hasLength(1),
        );
        expect(cubit.state.comments, hasLength(storedComments.length + 1));
        expect(cubit.state.post?.commentsCount, freshPost.commentsCount + 1);
      },
    );

    test(
      'l’événement reçu avant la réponse de l’envoi ne crée pas de doublon',
      () async {
        final cubit = await watchingCubit();
        final serverAnswer = Completer<Comment>();
        commentProvider.onCreate = (_, _) => serverAnswer.future;
        final ownComment = incomingComment('own-1');

        final sending = cubit.addComment('Mon commentaire');
        commentProvider.emitLive(CommentAdded(ownComment));
        await deliverLiveEvents();
        serverAnswer.complete(ownComment);

        expect(await sending, isTrue);
        expect(
          cubit.state.comments.where((comment) => comment.id == 'own-1'),
          hasLength(1),
        );
        expect(cubit.state.post?.commentsCount, freshPost.commentsCount + 1);
        expect(cubit.state.highlightedCommentId, 'own-1');
      },
    );

    test('un commentaire d’un autre post est ignoré', () async {
      final cubit = await watchingCubit();

      commentProvider.emitLive(
        CommentAdded(incomingComment('live-2', postId: 'autre-post')),
      );
      await deliverLiveEvents();

      expect(cubit.state.comments, storedComments);
      expect(cubit.state.post?.commentsCount, freshPost.commentsCount);
    });

    test('un commentaire supprimé disparaît et le compteur baisse', () async {
      final cubit = await watchingCubit();

      commentProvider.emitLive(CommentRemoved(storedComments.first.id));
      await deliverLiveEvents();

      expect(cubit.state.comments, [storedComments.last]);
      expect(cubit.state.post?.commentsCount, freshPost.commentsCount - 1);
    });

    test('la suppression d’un commentaire inconnu ne change rien', () async {
      final cubit = await watchingCubit();

      commentProvider.emitLive(const CommentRemoved('inconnu'));
      await deliverLiveEvents();

      expect(cubit.state.comments, storedComments);
      expect(cubit.state.post?.commentsCount, freshPost.commentsCount);
    });

    test('la fermeture du cubit coupe l’abonnement', () async {
      final cubit = buildCubit(initialPost: displayedPost)..watchComments();
      expect(commentProvider.hasLiveListener, isTrue);

      await cubit.close();

      expect(commentProvider.hasLiveListener, isFalse);
    });
  });
}
