import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

extension AuthNavigation on BuildContext {
  Future<bool> openLogin() async {
    final signedIn = await push<bool>(AppRoutes.login);
    return signedIn ?? false;
  }

  Future<bool> ensureSignedIn() async {
    if (read<AuthCubit>().state is AuthAuthenticated) {
      return true;
    }
    return openLogin();
  }

  void closeAuthFlow({required bool signedIn}) {
    if (canPop()) {
      pop(signedIn);
    } else {
      go(AppRoutes.feed);
    }
  }
}
