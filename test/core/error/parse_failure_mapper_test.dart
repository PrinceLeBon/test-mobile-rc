import 'dart:async';
import 'dart:io';

import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/core/error/parse_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() {
  Failure mapCode(int code, {String message = ''}) {
    return ParseFailureMapper.fromError(
      ParseError(code: code, message: message),
    );
  }

  group('ParseFailureMapper.fromError', () {
    test('142 garde le message du serveur', () {
      expect(
        mapCode(142, message: 'title must be 3-120 characters'),
        const ValidationFailure('title must be 3-120 characters'),
      );
    });

    test('142 sans message donne le texte par défaut', () {
      expect(
        mapCode(142, message: '  '),
        const ValidationFailure('Les données envoyées sont invalides.'),
      );
    });

    test('202, 203 et 125 donnent leur message propre', () {
      expect(
        mapCode(202),
        const ValidationFailure('Ce nom d’utilisateur est déjà pris.'),
      );
      expect(
        mapCode(203),
        const ValidationFailure('Cette adresse e-mail est déjà utilisée.'),
      );
      expect(mapCode(125), const ValidationFailure('Adresse e-mail invalide.'));
    });

    test('101 donne l’article introuvable par défaut', () {
      final failure = mapCode(101);
      expect(failure, isA<NotFoundFailure>());
      expect(
        failure.message,
        'Cet article n’existe plus ou vous n’y avez pas accès.',
      );
    });

    test('101 à la connexion donne les identifiants incorrects', () {
      final failure = ParseFailureMapper.fromError(
        ParseError(code: 101),
        notFoundMessage: FailureMessages.invalidCredentials,
      );
      expect(
        failure,
        const NotFoundFailure('Nom d’utilisateur ou mot de passe incorrect.'),
      );
    });

    test('209 donne une session expirée', () {
      final failure = mapCode(209);
      expect(failure, isA<SessionFailure>());
      expect(failure.message, 'Votre session a expiré. Reconnectez-vous.');
    });

    test('les erreurs réseau du SDK donnent une erreur réseau', () {
      for (final code in [-1, 100, 124]) {
        final failure = mapCode(code);
        expect(failure, isA<NetworkFailure>(), reason: 'code $code');
        expect(
          failure.message,
          'Impossible de joindre le serveur. Vérifiez votre connexion.',
        );
      }
    });

    test(
      'un code inconnu ou une erreur absente donnent une erreur inattendue',
      () {
        expect(mapCode(1), const UnknownFailure());
        expect(ParseFailureMapper.fromError(null), const UnknownFailure());
        expect(
          const UnknownFailure().message,
          'Une erreur inattendue est survenue. Réessayez.',
        );
      },
    );
  });

  group('ParseFailureMapper.fromResponse', () {
    test('lit l’erreur de la réponse', () {
      final response = ParseResponse(error: ParseError(code: 209));
      expect(ParseFailureMapper.fromResponse(response), const SessionFailure());
    });
  });

  group('ParseFailureMapper.fromException', () {
    test('reconnaît une ParseError levée', () {
      expect(
        ParseFailureMapper.fromException(ParseError(code: 202)),
        const ValidationFailure(FailureMessages.usernameTaken),
      );
    });

    test('reconnaît les pannes réseau de Dart', () {
      expect(
        ParseFailureMapper.fromException(const SocketException('refusé')),
        const NetworkFailure(),
      );
      expect(
        ParseFailureMapper.fromException(TimeoutException('lent')),
        const NetworkFailure(),
      );
    });

    test('une autre exception donne une erreur inattendue', () {
      expect(
        ParseFailureMapper.fromException(StateError('bug')),
        const UnknownFailure(),
      );
    });
  });
}
