import 'dart:async';

import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/data/models/post.dart';
import 'package:blog_app/data/repositories/post_repository.dart';
import 'package:blog_app/features/post/cubit/new_post_cubit.dart';
import 'package:blog_app/features/post/cubit/post_field_error.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_provider.dart';
import '../../../helpers/fake_post_provider.dart';

void main() {
  group('validation sur le texte nettoyé', () {
    test('le titre accepte de 3 à 120 caractères hors espaces', () {
      expect(PostFieldValidator.title('  ab  '), PostFieldError.titleTooShort);
      expect(PostFieldValidator.title('  abc  '), isNull);
      expect(PostFieldValidator.title(' ${'a' * 120} '), isNull);
      expect(PostFieldValidator.title('a' * 121), PostFieldError.titleTooLong);
    });

    test('le contenu accepte de 1 à 5000 caractères hors espaces', () {
      expect(PostFieldValidator.body('   \n  '), PostFieldError.bodyRequired);
      expect(PostFieldValidator.body(' x '), isNull);
      expect(PostFieldValidator.body(' ${'a' * 5000} '), isNull);
      expect(PostFieldValidator.body('a' * 5001), PostFieldError.bodyTooLong);
    });

    test('les messages reprennent exactement la maquette', () {
      expect(
        PostFieldError.titleTooShort.message,
        'Le titre doit contenir au moins 3 caractères.',
      );
      expect(
        PostFieldError.titleTooLong.message,
        'Le titre ne peut pas dépasser 120 caractères.',
      );
      expect(
        PostFieldError.bodyRequired.message,
        'Le contenu est obligatoire.',
      );
      expect(
        PostFieldError.bodyTooLong.message,
        'Le contenu ne peut pas dépasser 5000 caractères.',
      );
    });
  });

  group('publication', () {
    late FakePostProvider provider;
    late NewPostCubit cubit;

    setUp(() {
      provider = FakePostProvider();
      cubit = NewPostCubit(PostRepository(provider));
      addTearDown(cubit.close);
    });

    test(
      'un formulaire invalide montre les erreurs sans appeler le serveur',
      () async {
        cubit
          ..titleChanged('  ab ')
          ..bodyChanged('   ');
        await cubit.submit();

        expect(provider.createCalls, isEmpty);
        expect(cubit.state.titleError, PostFieldError.titleTooShort);
        expect(cubit.state.bodyError, PostFieldError.bodyRequired);
      },
    );

    test('envoie les valeurs nettoyées une seule fois', () async {
      final pending = Completer<Post>();
      provider.onCreate = (title, body) => pending.future;
      cubit
        ..titleChanged('  Mon titre  ')
        ..bodyChanged('\n Mon contenu \n');

      final first = cubit.submit();
      final second = cubit.submit();
      expect(cubit.state.isSubmitting, isTrue);
      pending.complete(samplePost(1));
      await Future.wait([first, second]);

      expect(provider.createCalls, [('Mon titre', 'Mon contenu')]);
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.createdPost, samplePost(1));
    });

    test('une erreur serveur est gardée pour le bandeau', () async {
      provider.onCreate = (title, body) => Future.error(parseError(209));
      cubit
        ..titleChanged('Mon titre')
        ..bodyChanged('Mon contenu');
      await cubit.submit();

      expect(cubit.state.failure, isA<SessionFailure>());
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.createdPost, isNull);
    });
  });
}
