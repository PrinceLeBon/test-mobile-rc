import 'package:equatable/equatable.dart';

abstract final class LikeFields {
  static const String className = 'Like';
  static const String post = 'post';
  static const String user = 'user';
  static const String toggleFunction = 'toggleLike';
  static const String postIdParameter = 'postId';
  static const String liked = 'liked';
  static const String likesCount = 'likesCount';
}

class LikeResult extends Equatable {
  const LikeResult({required this.liked, required this.likesCount});

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      liked: json[LikeFields.liked] == true,
      likesCount: (json[LikeFields.likesCount] as num?)?.toInt() ?? 0,
    );
  }

  final bool liked;
  final int likesCount;

  @override
  List<Object?> get props => [liked, likesCount];
}
