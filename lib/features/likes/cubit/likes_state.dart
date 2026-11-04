import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';

class PostLikeStatus extends Equatable {
  const PostLikeStatus({
    required this.likesCount,
    required this.registeredCount,
    this.liked = false,
    this.isPending = false,
  });

  final bool liked;
  final int likesCount;
  final int registeredCount;
  final bool isPending;

  PostLikeStatus copyWith({
    bool? liked,
    int? likesCount,
    int? registeredCount,
    bool? isPending,
  }) {
    return PostLikeStatus(
      liked: liked ?? this.liked,
      likesCount: likesCount ?? this.likesCount,
      registeredCount: registeredCount ?? this.registeredCount,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  List<Object?> get props => [liked, likesCount, registeredCount, isPending];
}

class LikesState extends Equatable {
  const LikesState({
    this.byPostId = const {},
    this.failure,
    this.failureCount = 0,
  });

  final Map<String, PostLikeStatus> byPostId;
  final Failure? failure;
  final int failureCount;

  LikesState copyWith({Map<String, PostLikeStatus>? byPostId}) {
    return LikesState(
      byPostId: byPostId ?? this.byPostId,
      failure: failure,
      failureCount: failureCount,
    );
  }

  LikesState withFailure(
    Failure failure,
    Map<String, PostLikeStatus> byPostId,
  ) {
    return LikesState(
      byPostId: byPostId,
      failure: failure,
      failureCount: failureCount + 1,
    );
  }

  @override
  List<Object?> get props => [byPostId, failure, failureCount];
}
