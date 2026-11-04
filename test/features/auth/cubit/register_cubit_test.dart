import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/features/auth/cubit/auth_field_error.dart';
import 'package:blog_app/features/auth/cubit/register_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_auth_provider.dart';

void main() {
  late FakeAuthProvider provider;
  late RegisterCubit cubit;

  setUp(() {
    provider = FakeAuthProvider();
    cubit = RegisterCubit(AuthRepository(provider));
  });

  tearDown(() => cubit.close());

  test('refuse un e-mail invalide et un mot de passe trop court', () async {
    cubit
      ..usernameChanged('prince')
      ..emailChanged('prince@exemple')
      ..passwordChanged('1234567');

    await cubit.submit();

    expect(cubit.state.usernameError, isNull);
    expect(cubit.state.emailError, AuthFieldError.invalidEmail);
    expect(cubit.state.passwordError, AuthFieldError.passwordTooShort);
    expect(provider.signUpCalls, isEmpty);
  });

  test('accepte un mot de passe de 8 caractères exactement', () async {
    cubit
      ..usernameChanged('prince')
      ..emailChanged('prince@exemple.com')
      ..passwordChanged('12345678');

    await cubit.submit();

    expect(provider.signUpCalls, hasLength(1));
  });

  test('envoie le nom et l’e-mail nettoyés', () async {
    cubit
      ..usernameChanged('  prince ')
      ..emailChanged(' prince@exemple.com  ')
      ..passwordChanged('Password123!');

    await cubit.submit();

    expect(provider.signUpCalls, [
      ('prince', 'prince@exemple.com', 'Password123!'),
    ]);
    expect(cubit.state.signedInUser?.username, 'prince');
  });

  test('affiche le message exact d’un nom déjà pris', () async {
    provider.onSignUp = (_, _, _) => throw parseError(ParseError.usernameTaken);
    cubit
      ..usernameChanged('alice')
      ..emailChanged('nouvelle@exemple.com')
      ..passwordChanged('Password123!');

    await cubit.submit();

    expect(cubit.state.failure?.message, 'Ce nom d’utilisateur est déjà pris.');
    expect(cubit.state.isSubmitting, isFalse);
  });
}
