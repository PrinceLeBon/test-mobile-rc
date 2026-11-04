import 'dart:io';

import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/fake_auth_provider.dart';

void main() {
  late FakeAuthProvider provider;
  late AuthRepository repository;

  setUp(() {
    provider = FakeAuthProvider();
    repository = AuthRepository(provider);
  });

  Failure? failureOf<T>(Either<Failure, T> result) {
    return result.fold((failure) => failure, (_) => null);
  }

  group('logIn', () {
    test('renvoie l’utilisateur connecté', () async {
      final result = await repository.logIn(
        username: 'alice',
        password: 'Password123!',
      );

      expect(result, const Right<Failure, AppUser>(alice));
      expect(provider.logInCalls, [('alice', 'Password123!')]);
    });

    test('traduit le code 101 en identifiants incorrects', () async {
      provider.onLogIn = (_, _) => throw parseError(ParseError.objectNotFound);

      final failure = failureOf(
        await repository.logIn(username: 'alice', password: 'faux'),
      );

      expect(failure, isA<NotFoundFailure>());
      expect(failure?.message, 'Nom d’utilisateur ou mot de passe incorrect.');
    });

    test('traduit une coupure réseau en NetworkFailure', () async {
      provider.onLogIn = (_, _) =>
          throw const SocketException('Connexion refusée');

      final failure = failureOf(
        await repository.logIn(username: 'alice', password: 'Password123!'),
      );

      expect(failure, const NetworkFailure());
      expect(
        failure?.message,
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
      );
    });
  });

  group('signUp', () {
    test('traduit le code 202 en nom déjà pris', () async {
      provider.onSignUp = (_, _, _) =>
          throw parseError(ParseError.usernameTaken);

      final failure = failureOf(
        await repository.signUp(
          username: 'alice',
          email: 'nouveau@example.com',
          password: 'Password123!',
        ),
      );

      expect(failure?.message, 'Ce nom d’utilisateur est déjà pris.');
    });

    test('traduit le code 203 en e-mail déjà utilisé', () async {
      provider.onSignUp = (_, _, _) => throw parseError(ParseError.emailTaken);

      final failure = failureOf(
        await repository.signUp(
          username: 'nouveau',
          email: 'alice@example.com',
          password: 'Password123!',
        ),
      );

      expect(failure?.message, 'Cette adresse e-mail est déjà utilisée.');
    });
  });

  group('verifySession', () {
    test('efface la session locale quand le serveur répond 209', () async {
      provider.onFetchCurrentUser = () =>
          throw parseError(ParseError.invalidSessionToken);

      final failure = failureOf(await repository.verifySession());

      expect(failure, const SessionFailure());
      expect(provider.clearLocalSessionCalls, 1);
    });

    test('garde la session locale quand le serveur est injoignable', () async {
      provider.onFetchCurrentUser = () =>
          throw const SocketException('Connexion refusée');

      final failure = failureOf(await repository.verifySession());

      expect(failure, const NetworkFailure());
      expect(provider.clearLocalSessionCalls, 0);
    });
  });

  test('storedUser renvoie null sans session enregistrée', () async {
    final result = await repository.storedUser();

    expect(result, const Right<Failure, AppUser?>(null));
  });

  test('logOut renvoie l’échec sans le propager', () async {
    provider.onLogOut = () => throw parseError(ParseError.invalidSessionToken);

    final result = await repository.logOut();

    expect(result, isA<Left<Failure, Object>>());
    expect(provider.logOutCalls, 1);
  });
}
