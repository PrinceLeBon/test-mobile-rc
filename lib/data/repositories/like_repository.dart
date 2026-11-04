import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../../core/error/failure.dart';
import '../../core/error/parse_failure_mapper.dart';
import '../models/like_result.dart';
import '../providers/like_provider.dart';

class LikeRepository {
  LikeRepository(this._provider);

  final LikeProvider _provider;

  Future<Either<Failure, LikeResult>> toggle(String postId) {
    return _run(() => _provider.toggle(postId));
  }

  Future<Either<Failure, Set<String>>> fetchLikedPostIds(List<String> postIds) {
    if (postIds.isEmpty) {
      return Future.value(const Right(<String>{}));
    }
    return _run(() => _provider.fetchLikedPostIds(postIds));
  }

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(ParseFailureMapper.fromException(error));
    }
  }
}
