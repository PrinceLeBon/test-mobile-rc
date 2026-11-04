import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/post_repository.dart';
import 'new_post_state.dart';

class NewPostCubit extends Cubit<NewPostState> {
  NewPostCubit(this._repository) : super(const NewPostState());

  final PostRepository _repository;

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void bodyChanged(String value) {
    emit(state.copyWith(body: value));
  }

  Future<void> submit() async {
    if (state.isSubmitting || state.createdPost != null) {
      return;
    }
    if (!state.isValid) {
      emit(state.copyWith(showFieldErrors: true, failure: () => null));
      return;
    }
    emit(
      state.copyWith(
        showFieldErrors: true,
        isSubmitting: true,
        failure: () => null,
      ),
    );
    final result = await _repository.create(
      title: state.title.trim(),
      body: state.body.trim(),
    );
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, failure: () => failure)),
      (post) =>
          emit(state.copyWith(isSubmitting: false, createdPost: () => post)),
    );
  }
}
