import '../cubit/auth_field_error.dart';

extension AuthFieldErrorMessage on AuthFieldError {
  String get message => switch (this) {
    AuthFieldError.usernameRequired => 'Saisissez votre nom d’utilisateur.',
    AuthFieldError.passwordRequired => 'Saisissez votre mot de passe.',
    AuthFieldError.invalidEmail => 'Adresse e-mail invalide.',
    AuthFieldError.passwordTooShort => '8 caractères minimum.',
  };
}
