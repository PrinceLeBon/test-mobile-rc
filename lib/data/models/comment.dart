import 'package:equatable/equatable.dart';

abstract final class CommentFields {
  static const String className = 'Comment';
  static const String objectId = 'objectId';
  static const String post = 'post';
  static const String author = 'author';
  static const String text = 'text';
  static const String createdAt = 'createdAt';
  static const String authorUsername = 'username';
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.postId,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  static const String unknownAuthorName = 'Auteur inconnu';

  final String id;
  final String postId;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    postId,
    text,
    authorId,
    authorName,
    createdAt,
  ];
}
