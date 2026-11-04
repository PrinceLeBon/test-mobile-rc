import 'dart:async';
import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'failure.dart';

abstract final class ParseFailureMapper {
  static Failure fromResponse(
    ParseResponse response, {
    String notFoundMessage = FailureMessages.notFound,
  }) {
    return fromError(response.error, notFoundMessage: notFoundMessage);
  }

  static Failure fromException(
    Object exception, {
    String notFoundMessage = FailureMessages.notFound,
  }) {
    return switch (exception) {
      ParseError() => fromError(exception, notFoundMessage: notFoundMessage),
      SocketException() || TimeoutException() => const NetworkFailure(),
      _ => const UnknownFailure(),
    };
  }

  static Failure fromError(
    ParseError? error, {
    String notFoundMessage = FailureMessages.notFound,
  }) {
    if (error == null) {
      return const UnknownFailure();
    }
    return switch (error.code) {
      ParseError.validationError => ValidationFailure(
        _serverMessageOrDefault(error.message),
      ),
      ParseError.usernameTaken => const ValidationFailure(
        FailureMessages.usernameTaken,
      ),
      ParseError.emailTaken => const ValidationFailure(
        FailureMessages.emailTaken,
      ),
      ParseError.invalidEmailAddress => const ValidationFailure(
        FailureMessages.invalidEmail,
      ),
      ParseError.objectNotFound => NotFoundFailure(notFoundMessage),
      ParseError.invalidSessionToken => const SessionFailure(),
      ParseError.otherCause ||
      ParseError.connectionFailed ||
      ParseError.timeout => const NetworkFailure(),
      _ => const UnknownFailure(),
    };
  }

  static String _serverMessageOrDefault(String message) {
    final trimmedMessage = message.trim();
    return trimmedMessage.isEmpty
        ? FailureMessages.invalidData
        : trimmedMessage;
  }
}
