import '../../../core/constants/validation_rules.dart';

enum PostFieldError {
  titleTooShort('Le titre doit contenir au moins 3 caractères.'),
  titleTooLong('Le titre ne peut pas dépasser 120 caractères.'),
  bodyRequired('Le contenu est obligatoire.'),
  bodyTooLong('Le contenu ne peut pas dépasser 5000 caractères.');

  const PostFieldError(this.message);

  final String message;
}

abstract final class PostFieldValidator {
  static PostFieldError? title(String rawValue) {
    final length = rawValue.trim().length;
    if (length < ValidationRules.postTitleMinLength) {
      return PostFieldError.titleTooShort;
    }
    if (length > ValidationRules.postTitleMaxLength) {
      return PostFieldError.titleTooLong;
    }
    return null;
  }

  static PostFieldError? body(String rawValue) {
    final length = rawValue.trim().length;
    if (length < ValidationRules.postBodyMinLength) {
      return PostFieldError.bodyRequired;
    }
    if (length > ValidationRules.postBodyMaxLength) {
      return PostFieldError.bodyTooLong;
    }
    return null;
  }
}
