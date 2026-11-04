import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/post.dart';
import 'post_field_error.dart';

final class NewPostState extends Equatable {
  const NewPostState({
    this.title = '',
    this.body = '',
    this.showFieldErrors = false,
    this.isSubmitting = false,
    this.failure,
    this.createdPost,
  });

  final String title;
  final String body;
  final bool showFieldErrors;
  final bool isSubmitting;
  final Failure? failure;
  final Post? createdPost;

  PostFieldError? get titleError =>
      showFieldErrors ? PostFieldValidator.title(title) : null;

  PostFieldError? get bodyError =>
      showFieldErrors ? PostFieldValidator.body(body) : null;

  bool get isValid =>
      PostFieldValidator.title(title) == null &&
      PostFieldValidator.body(body) == null;

  NewPostState copyWith({
    String? title,
    String? body,
    bool? showFieldErrors,
    bool? isSubmitting,
    ValueGetter<Failure?>? failure,
    ValueGetter<Post?>? createdPost,
  }) {
    return NewPostState(
      title: title ?? this.title,
      body: body ?? this.body,
      showFieldErrors: showFieldErrors ?? this.showFieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
      createdPost: createdPost == null ? this.createdPost : createdPost(),
    );
  }

  @override
  List<Object?> get props => [
    title,
    body,
    showFieldErrors,
    isSubmitting,
    failure,
    createdPost,
  ];
}
