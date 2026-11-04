import 'dart:async';

import 'package:blog_app/data/models/like_result.dart';
import 'package:blog_app/data/providers/like_provider.dart';

class FakeLikeProvider implements LikeProvider {
  FakeLikeProvider({this.likedPostIds = const {}});

  final Set<String> likedPostIds;
  final List<String> toggledPostIds = [];
  Completer<LikeResult> pendingToggle = Completer<LikeResult>();

  @override
  Future<LikeResult> toggle(String postId) {
    toggledPostIds.add(postId);
    return pendingToggle.future;
  }

  @override
  Future<Set<String>> fetchLikedPostIds(List<String> postIds) async {
    return postIds.where(likedPostIds.contains).toSet();
  }
}
