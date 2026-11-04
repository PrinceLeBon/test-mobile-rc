import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../../core/error/failure.dart';
import '../../core/error/parse_failure_mapper.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

class PostRepository {
  PostRepository(this._provider);

  static const int pageSize = 10;

  final PostProvider _provider;

  Future<Either<Failure, List<Post>>> fetchPage({required int skip}) {
    return _run(() => _provider.fetchPage(skip: skip, limit: pageSize));
  }

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(ParseFailureMapper.fromException(error));
    }
  }
}
