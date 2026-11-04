import 'package:equatable/equatable.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract final class PostFields {
  static const String className = 'Post';
  static const String title = 'title';
  static const String body = 'body';
  static const String author = 'author';
  static const String likesCount = 'likesCount';
  static const String commentsCount = 'commentsCount';
  static const String createdAt = 'createdAt';
  static const String authorUsername = 'username';
}

class Post extends Equatable {
  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Post.fromParseObject(ParseObject object) {
    final author = object.get<ParseObject>(PostFields.author);
    return Post(
      id: object.objectId ?? '',
      title: object.get<String>(PostFields.title) ?? '',
      body: object.get<String>(PostFields.body) ?? '',
      authorId: author?.objectId ?? '',
      authorName:
          author?.get<String>(PostFields.authorUsername) ?? unknownAuthorName,
      createdAt: object.createdAt ?? DateTime.now(),
      likesCount: object.get<num>(PostFields.likesCount)?.toInt() ?? 0,
      commentsCount: object.get<num>(PostFields.commentsCount)?.toInt() ?? 0,
    );
  }

  static const String unknownAuthorName = 'Auteur inconnu';

  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;

  bool isWrittenBy(String? userId) => userId != null && userId == authorId;

  Post copyWith({
    String? title,
    String? body,
    int? likesCount,
    int? commentsCount,
  }) {
    return Post(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorId: authorId,
      authorName: authorName,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    authorId,
    authorName,
    createdAt,
    likesCount,
    commentsCount,
  ];
}
