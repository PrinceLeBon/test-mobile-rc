import 'package:equatable/equatable.dart';

abstract final class FailureMessages {
  static const String invalidData = 'Les données envoyées sont invalides.';
  static const String usernameTaken = 'Ce nom d’utilisateur est déjà pris.';
  static const String emailTaken = 'Cette adresse e-mail est déjà utilisée.';
  static const String invalidEmail = 'Adresse e-mail invalide.';
  static const String invalidCredentials =
      'Nom d’utilisateur ou mot de passe incorrect.';
  static const String notFound =
      'Cet article n’existe plus ou vous n’y avez pas accès.';
  static const String sessionExpired =
      'Votre session a expiré. Reconnectez-vous.';
  static const String network =
      'Impossible de joindre le serveur. Vérifiez votre connexion.';
  static const String unknown =
      'Une erreur inattendue est survenue. Réessayez.';
}

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = FailureMessages.invalidData]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = FailureMessages.notFound]);
}

final class SessionFailure extends Failure {
  const SessionFailure() : super(FailureMessages.sessionExpired);
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super(FailureMessages.network);
}

final class UnknownFailure extends Failure {
  const UnknownFailure() : super(FailureMessages.unknown);
}
