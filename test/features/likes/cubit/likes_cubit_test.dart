import 'package:blog_app/data/models/like_result.dart';
import 'package:blog_app/data/repositories/like_repository.dart';
import 'package:blog_app/features/likes/cubit/likes_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_like_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  late FakeLikeProvider provider;
  late LikesCubit cubit;
  final post = samplePost(1);

  setUp(() async {
    provider = FakeLikeProvider(likedPostIds: {post.id});
    cubit = LikesCubit(LikeRepository(provider));
    await cubit.userChanged('alice');
    await cubit.registerPosts([post]);
  });

  tearDown(() => cubit.close());

  test('charge le like personnel des articles enregistrés', () {
    expect(cubit.state.byPostId[post.id]?.liked, isTrue);
    expect(cubit.state.byPostId[post.id]?.likesCount, post.likesCount);
  });

  test('bascule tout de suite et ignore une seconde touche en cours', () async {
    final toggle = cubit.toggle(post.id);
    await cubit.toggle(post.id);

    expect(cubit.state.byPostId[post.id]?.liked, isFalse);
    expect(cubit.state.byPostId[post.id]?.isPending, isTrue);
    expect(provider.toggledPostIds, [post.id]);

    provider.pendingToggle.complete(
      LikeResult(liked: false, likesCount: post.likesCount - 1),
    );
    await toggle;

    expect(cubit.state.byPostId[post.id]?.isPending, isFalse);
    expect(cubit.state.byPostId[post.id]?.likesCount, post.likesCount - 1);
  });

  test('revient en arrière et signale l’échec', () async {
    final toggle = cubit.toggle(post.id);
    provider.pendingToggle.completeError(ParseError(code: ParseError.timeout));
    await toggle;

    expect(cubit.state.byPostId[post.id]?.liked, isTrue);
    expect(cubit.state.byPostId[post.id]?.likesCount, post.likesCount);
    expect(cubit.state.byPostId[post.id]?.isPending, isFalse);
    expect(cubit.state.failureCount, 1);
  });

  test('remet les likes personnels à faux à la déconnexion', () async {
    await cubit.userChanged(null);

    expect(cubit.state.byPostId[post.id]?.liked, isFalse);
  });
}
