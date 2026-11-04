import 'dart:async';

import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/features/auth/cubit/auth_field_error.dart';
import 'package:blog_app/features/auth/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_auth_provider.dart';

void main() {
  late FakeAuthProvider provider;
  late LoginCubit cubit;

  setUp(() {
    provider = FakeAuthProvider();
    cubit = LoginCubit(AuthRepository(provider));
  });

  tearDown(() => cubit.close());

  test('n’affiche aucune erreur avant le premier envoi', () {
    expect(cubit.state.usernameError, isNull);
    expect(cubit.state.passwordError, isNull);
  });

  test('bloque l’envoi et montre les erreurs des champs vides', () async {
    cubit.usernameChanged('   ');

    await cubit.submit();

    expect(cubit.state.usernameError, AuthFieldError.usernameRequired);
    expect(cubit.state.passwordError, AuthFieldError.passwordRequired);
    expect(provider.logInCalls, isEmpty);
  });

  test('met à jour les erreurs pendant la saisie après un envoi', () async {
    await cubit.submit();
    cubit.usernameChanged('alice');

    expect(cubit.state.usernameError, isNull);
    expect(cubit.state.passwordError, AuthFieldError.passwordRequired);
  });

  test('nettoie le nom mais pas le mot de passe', () async {
    cubit
      ..usernameChanged('  alice  ')
      ..passwordChanged(' Password123! ');

    await cubit.submit();

    expect(provider.logInCalls, [('alice', ' Password123! ')]);
    expect(cubit.state.signedInUser, alice);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('n’envoie qu’une requête pendant un envoi en cours', () async {
    final response = Completer<AppUser>();
    provider.onLogIn = (_, _) => response.future;
    cubit
      ..usernameChanged('alice')
      ..passwordChanged('Password123!');

    final firstSubmit = cubit.submit();
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.submit();
    response.complete(alice);
    await firstSubmit;

    expect(provider.logInCalls, hasLength(1));
  });

  test('garde l’erreur serveur et réactive le formulaire', () async {
    provider.onLogIn = (_, _) => throw parseError(ParseError.objectNotFound);
    cubit
      ..usernameChanged('alice')
      ..passwordChanged('faux');

    await cubit.submit();

    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.signedInUser, isNull);
    expect(
      cubit.state.failure,
      const NotFoundFailure('Nom d’utilisateur ou mot de passe incorrect.'),
    );
  });

  test('efface l’erreur serveur au nouvel envoi', () async {
    final response = Completer<AppUser>();
    provider.onLogIn = (_, _) => throw parseError(ParseError.objectNotFound);
    cubit
      ..usernameChanged('alice')
      ..passwordChanged('faux');
    await cubit.submit();
    provider.onLogIn = (_, _) => response.future;

    final secondSubmit = cubit.submit();

    expect(cubit.state.failure, isNull);
    response.complete(alice);
    await secondSubmit;
  });
}
