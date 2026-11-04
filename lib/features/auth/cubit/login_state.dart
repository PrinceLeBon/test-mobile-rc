import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/app_user.dart';
import 'auth_field_error.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.showFieldErrors = false,
    this.isSubmitting = false,
    this.failure,
    this.signedInUser,
  });

  final String username;
  final String password;
  final bool showFieldErrors;
  final bool isSubmitting;
  final Failure? failure;
  final AppUser? signedInUser;

  AuthFieldError? get usernameError =>
      showFieldErrors ? AuthFieldValidator.username(username) : null;

  AuthFieldError? get passwordError =>
      showFieldErrors ? AuthFieldValidator.loginPassword(password) : null;

  bool get isValid =>
      AuthFieldValidator.username(username) == null &&
      AuthFieldValidator.loginPassword(password) == null;

  LoginState copyWith({
    String? username,
    String? password,
    bool? showFieldErrors,
    bool? isSubmitting,
    ValueGetter<Failure?>? failure,
    ValueGetter<AppUser?>? signedInUser,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      showFieldErrors: showFieldErrors ?? this.showFieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
      signedInUser: signedInUser == null ? this.signedInUser : signedInUser(),
    );
  }

  @override
  List<Object?> get props => [
    username,
    password,
    showFieldErrors,
    isSubmitting,
    failure,
    signedInUser,
  ];
}
