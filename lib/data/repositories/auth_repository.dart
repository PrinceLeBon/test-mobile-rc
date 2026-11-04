import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;

import '../../core/error/failure.dart';
import '../../core/error/parse_failure_mapper.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  AuthRepository(this._provider);

  final AuthProvider _provider;

  Future<Either<Failure, AppUser?>> storedUser() {
    return _run(_provider.currentUser);
  }

  Future<Either<Failure, AppUser>> verifySession() async {
    final result = await _run(_provider.fetchCurrentUser);
    final failure = result.fold((failure) => failure, (_) => null);
    if (failure is SessionFailure) {
      await clearSession();
    }
    return result;
  }

  Future<Either<Failure, AppUser>> logIn({
    required String username,
    required String password,
  }) {
    return _run(
      () => _provider.logIn(username: username, password: password),
      notFoundMessage: FailureMessages.invalidCredentials,
    );
  }

  Future<Either<Failure, AppUser>> signUp({
    required String username,
    required String email,
    required String password,
  }) {
    return _run(
      () => _provider.signUp(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, Unit>> logOut() {
    return _run(() async {
      await _provider.logOut();
      return unit;
    });
  }

  Future<Either<Failure, Unit>> clearSession() {
    return _run(() async {
      await _provider.clearLocalSession();
      return unit;
    });
  }

  Future<Either<Failure, T>> _run<T>(
    Future<T> Function() action, {
    String notFoundMessage = FailureMessages.notFound,
  }) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(
        ParseFailureMapper.fromException(
          error,
          notFoundMessage: notFoundMessage,
        ),
      );
    }
  }
}
