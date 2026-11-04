import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  void usernameChanged(String value) {
    emit(state.copyWith(username: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> submit() async {
    if (state.isSubmitting || state.signedInUser != null) {
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
    final result = await _repository.logIn(
      username: state.username.trim(),
      password: state.password,
    );
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, failure: () => failure)),
      (user) =>
          emit(state.copyWith(isSubmitting: false, signedInUser: () => user)),
    );
  }
}
