import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/app_user.dart';
import 'auth_field_error.dart';

final class RegisterState extends Equatable {
  const RegisterState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.showFieldErrors = false,
    this.isSubmitting = false,
    this.failure,
    this.signedInUser,
  });

  final String username;
  final String email;
  final String password;
  final bool showFieldErrors;
  final bool isSubmitting;
  final Failure? failure;
  final AppUser? signedInUser;

  AuthFieldError? get usernameError =>
      showFieldErrors ? AuthFieldValidator.username(username) : null;

  AuthFieldError? get emailError =>
      showFieldErrors ? AuthFieldValidator.email(email) : null;

  AuthFieldError? get passwordError =>
      showFieldErrors ? AuthFieldValidator.newPassword(password) : null;

  bool get isValid =>
      AuthFieldValidator.username(username) == null &&
      AuthFieldValidator.email(email) == null &&
      AuthFieldValidator.newPassword(password) == null;

  RegisterState copyWith({
    String? username,
    String? email,
    String? password,
    bool? showFieldErrors,
    bool? isSubmitting,
    ValueGetter<Failure?>? failure,
    ValueGetter<AppUser?>? signedInUser,
  }) {
    return RegisterState(
      username: username ?? this.username,
      email: email ?? this.email,
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
    email,
    password,
    showFieldErrors,
    isSubmitting,
    failure,
    signedInUser,
  ];
}
