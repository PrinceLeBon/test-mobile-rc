import '../../../core/constants/validation_rules.dart';

enum AuthFieldError {
  usernameRequired,
  passwordRequired,
  invalidEmail,
  passwordTooShort,
}

abstract final class AuthFieldValidator {
  static AuthFieldError? username(String value) {
    return value.trim().isEmpty ? AuthFieldError.usernameRequired : null;
  }

  static AuthFieldError? loginPassword(String value) {
    return value.isEmpty ? AuthFieldError.passwordRequired : null;
  }

  static AuthFieldError? email(String value) {
    return ValidationRules.emailPattern.hasMatch(value.trim())
        ? null
        : AuthFieldError.invalidEmail;
  }

  static AuthFieldError? newPassword(String value) {
    if (value.isEmpty) {
      return AuthFieldError.passwordRequired;
    }
    if (value.length < ValidationRules.signUpPasswordMinLength) {
      return AuthFieldError.passwordTooShort;
    }
    return null;
  }
}
