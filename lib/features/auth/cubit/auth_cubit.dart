import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthUnknown());

  final AuthRepository _repository;

  AppUser? get currentUser => switch (state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };

  Future<void> restoreSession() async {
    final storedResult = await _repository.storedUser();
    if (isClosed) {
      return;
    }
    final storedUser = storedResult.fold((_) => null, (user) => user);
    if (storedUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(storedUser));

    final verifiedResult = await _repository.verifySession();
    if (isClosed || currentUser?.id != storedUser.id) {
      return;
    }
    verifiedResult.fold((failure) {
      if (failure is SessionFailure) {
        emit(const AuthUnauthenticated());
      }
    }, (verifiedUser) => emit(AuthAuthenticated(verifiedUser)));
  }

  void signedIn(AppUser user) {
    emit(AuthAuthenticated(user));
  }

  Future<void> logOut() async {
    emit(const AuthUnauthenticated());
    await _repository.logOut();
  }

  Future<void> sessionExpired() async {
    emit(const AuthUnauthenticated());
    await _repository.clearSession();
  }
}
