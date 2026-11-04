import 'dart:async';

import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/data/models/post.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/feed/cubit/feed_cubit.dart';
import 'package:blog_app/features/feed/cubit/feed_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_post_provider.dart';

void main() {
  late FakePostProvider provider;
  late FeedCubit cubit;

  setUp(() {
    provider = FakePostProvider(posts: samplePosts(25));
    cubit = FeedCubit(PostRepository(provider));
  });

  tearDown(() => cubit.close());

  List<int> requestedSkips() =>
      provider.fetchPageCalls.map((call) => call.$1).toList();

  test(
    'le premier chargement affiche les 10 articles les plus récents',
    () async {
      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const FeedState(status: FeedStatus.loading),
          FeedState(status: FeedStatus.success, posts: samplePosts(10)),
        ]),
      );

      await cubit.loadInitial();

      await states;
      expect(provider.fetchPageCalls, [(0, PostRepository.pageSize)]);
    },
  );

  test(
    'les 25 articles se parcourent en 3 pages puis la fin est atteinte',
    () async {
      await cubit.loadInitial();
      await cubit.loadMore();
      await cubit.loadMore();

      expect(cubit.state.posts, samplePosts(25));
      expect(cubit.state.hasReachedEnd, isTrue);
      expect(requestedSkips(), [0, 10, 20]);

      await cubit.loadMore();

      expect(requestedSkips(), [0, 10, 20]);
    },
  );

  test('une page suivante déjà en cours ne relance pas de requête', () async {
    await cubit.loadInitial();
    final pendingPage = Completer<List<Post>>();
    provider.onFetchPage = (skip, limit) => pendingPage.future;

    final firstCall = cubit.loadMore();
    final secondCall = cubit.loadMore();

    expect(cubit.state.isLoadingMore, isTrue);
    expect(requestedSkips(), [0, 10]);

    pendingPage.complete(samplePosts(20).sublist(10));
    await Future.wait([firstCall, secondCall]);

    expect(cubit.state.posts, samplePosts(20));
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test('l’échec du premier chargement affiche l’erreur', () async {
    provider.onFetchPage = (skip, limit) =>
        Future.error(const UnexpectedError());

    await cubit.loadInitial();

    expect(cubit.state.status, FeedStatus.failure);
    expect(cubit.state.failure, const UnknownFailure());
    expect(cubit.state.posts, isEmpty);
  });

  test('l’échec de la page suivante garde la liste et se réessaie', () async {
    await cubit.loadInitial();
    provider.onFetchPage = (skip, limit) => Future.error(
      ParseError(code: ParseError.connectionFailed, message: 'réseau'),
    );

    await cubit.loadMore();

    expect(cubit.state.posts, samplePosts(10));
    expect(cubit.state.loadMoreFailure, const NetworkFailure());
    expect(cubit.state.isLoadingMore, isFalse);

    await cubit.loadMore();
    expect(requestedSkips(), [0, 10]);

    provider.onFetchPage = null;
    await cubit.retryLoadMore();

    expect(requestedSkips(), [0, 10, 10]);
    expect(cubit.state.posts, samplePosts(20));
    expect(cubit.state.loadMoreFailure, isNull);
  });

  test(
    'le rafraîchissement recharge la première page en gardant la liste',
    () async {
      await cubit.loadInitial();
      await cubit.loadMore();
      provider.posts = [samplePost(99), ...samplePosts(25)];
      final pendingPage = Completer<List<Post>>();
      provider.onFetchPage = (skip, limit) => pendingPage.future;

      final refreshing = cubit.refresh();

      expect(cubit.state.isRefreshing, isTrue);
      expect(cubit.state.posts, samplePosts(20));

      pendingPage.complete(provider.posts.take(10).toList());
      await refreshing;

      expect(requestedSkips(), [0, 10, 0]);
      expect(cubit.state.posts.first, samplePost(99));
      expect(cubit.state.posts, hasLength(10));
      expect(cubit.state.isRefreshing, isFalse);
      expect(cubit.state.hasReachedEnd, isFalse);
    },
  );

  test(
    'l’échec du rafraîchissement garde la liste et signale l’erreur',
    () async {
      await cubit.loadInitial();
      provider.onFetchPage = (skip, limit) => Future.error(
        ParseError(code: ParseError.connectionFailed, message: 'réseau'),
      );

      await cubit.refresh();

      expect(cubit.state.status, FeedStatus.success);
      expect(cubit.state.posts, samplePosts(10));
      expect(cubit.state.refreshFailure, const NetworkFailure());
      expect(cubit.state.isRefreshing, isFalse);
    },
  );

  test(
    'une page suivante arrivée après un rafraîchissement est ignorée',
    () async {
      await cubit.loadInitial();
      final pendingNextPage = Completer<List<Post>>();
      provider.onFetchPage = (skip, limit) => pendingNextPage.future;
      final loadingMore = cubit.loadMore();

      provider.onFetchPage = null;
      await cubit.refresh();
      pendingNextPage.complete(samplePosts(20).sublist(10));
      await loadingMore;

      expect(cubit.state.posts, samplePosts(10));
      expect(cubit.state.isLoadingMore, isFalse);
    },
  );

  test(
    'replacePost met à jour la carte du même article sans recharger',
    () async {
      await cubit.loadInitial();
      final updatedPost = samplePost(3).copyWith(commentsCount: 42);

      cubit.replacePost(updatedPost);

      expect(cubit.state.posts[3], updatedPost);
      expect(cubit.state.posts.length, 10);
      expect(
        cubit.state.posts.where((post) => post != updatedPost),
        samplePosts(10).where((post) => post.id != updatedPost.id),
      );
      expect(provider.fetchPageCalls.length, 1);
    },
  );

  test('replacePost ignore un article absent du fil', () async {
    await cubit.loadInitial();
    final stateBefore = cubit.state;

    cubit.replacePost(samplePost(40));

    expect(cubit.state, same(stateBefore));
  });
}

class UnexpectedError implements Exception {
  const UnexpectedError();
}
