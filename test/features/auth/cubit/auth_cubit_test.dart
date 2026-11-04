import 'dart:async';
import 'dart:io';

import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/features/auth/cubit/auth_cubit.dart';
import 'package:blog_app/features/auth/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_auth_provider.dart';

void main() {
  const refreshedAlice = AppUser(
    id: 'u1',
    username: 'alice',
    email: 'alice@nouveau.example.com',
  );

  late FakeAuthProvider provider;
  late AuthCubit cubit;

  setUp(() {
    provider = FakeAuthProvider();
    cubit = AuthCubit(AuthRepository(provider));
  });

  tearDown(() => cubit.close());

  test('démarre dans un état inconnu', () {
    expect(cubit.state, const AuthUnknown());
  });

  group('restoreSession', () {
    test('passe en visiteur sans session enregistrée', () async {
      await cubit.restoreSession();

      expect(cubit.state, const AuthUnauthenticated());
      expect(cubit.currentUser, isNull);
    });

    test('connecte avec la session locale puis la confirme', () async {
      provider.onCurrentUser = () async => alice;
      provider.onFetchCurrentUser = () async => refreshedAlice;
      final emittedStates = expectLater(
        cubit.stream,
        emitsInOrder(const [
          AuthAuthenticated(alice),
          AuthAuthenticated(refreshedAlice),
        ]),
      );

      await cubit.restoreSession();
      await emittedStates;
    });

    test('déconnecte proprement une session invalide (209)', () async {
      provider.onCurrentUser = () async => alice;
      provider.onFetchCurrentUser = () =>
          throw parseError(ParseError.invalidSessionToken);

      await cubit.restoreSession();

      expect(cubit.state, const AuthUnauthenticated());
      expect(provider.clearLocalSessionCalls, 1);
    });

    test('garde l’utilisateur local hors ligne', () async {
      provider.onCurrentUser = () async => alice;
      provider.onFetchCurrentUser = () =>
          throw const SocketException('Connexion refusée');

      await cubit.restoreSession();

      expect(cubit.state, const AuthAuthenticated(alice));
      expect(provider.clearLocalSessionCalls, 0);
    });

    test(
      'ne reconnecte pas après une déconnexion pendant la vérification',
      () async {
        final verification = Completer<AppUser>();
        provider.onCurrentUser = () async => alice;
        provider.onFetchCurrentUser = () => verification.future;

        final restoring = cubit.restoreSession();
        await Future<void>.delayed(Duration.zero);
        await cubit.logOut();
        verification.complete(alice);
        await restoring;

        expect(cubit.state, const AuthUnauthenticated());
      },
    );
  });

  test('signedIn connecte l’utilisateur', () {
    cubit.signedIn(alice);

    expect(cubit.state, const AuthAuthenticated(alice));
    expect(cubit.currentUser, alice);
  });

  test('logOut repasse en visiteur et ferme la session', () async {
    cubit.signedIn(alice);

    await cubit.logOut();

    expect(cubit.state, const AuthUnauthenticated());
    expect(provider.logOutCalls, 1);
  });

  test('logOut repasse en visiteur même si le serveur échoue', () async {
    provider.onLogOut = () => throw const SocketException('Connexion refusée');
    cubit.signedIn(alice);

    await cubit.logOut();

    expect(cubit.state, const AuthUnauthenticated());
  });

  test('sessionExpired déconnecte et efface la session locale', () async {
    cubit.signedIn(alice);

    await cubit.sessionExpired();

    expect(cubit.state, const AuthUnauthenticated());
    expect(provider.clearLocalSessionCalls, 1);
  });
}
