import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../../core/error/failure.dart';
import '../../core/error/parse_failure_mapper.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';

class CommentRepository {
  CommentRepository(this._provider);

  static const int maxCommentsPerPost = 100;

  final CommentProvider _provider;

  Future<Either<Failure, List<Comment>>> fetchForPost(String postId) {
    return _run(
      () => _provider.fetchForPost(postId, limit: maxCommentsPerPost),
    );
  }

  Future<Either<Failure, Comment>> create({
    required String postId,
    required String text,
  }) {
    return _run(() => _provider.create(postId: postId, text: text));
  }

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(ParseFailureMapper.fromException(error));
    }
  }
}
