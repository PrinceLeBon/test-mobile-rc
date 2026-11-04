import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/likes_cubit.dart';
import '../cubit/likes_state.dart';

abstract final class LikeTexts {
  static const String toggleFailed = 'Votre like n’a pas pu être enregistré.';
}

class LikesSync extends StatefulWidget {
  const LikesSync({super.key, required this.child});

  final Widget child;

  @override
  State<LikesSync> createState() => _LikesSyncState();
}

class _LikesSyncState extends State<LikesSync> {
  @override
  void initState() {
    super.initState();
    _syncUser(context.read<AuthCubit>().state);
  }

  void _syncUser(AuthState authState) {
    final likesCubit = context.read<LikesCubit>();
    switch (authState) {
      case AuthUnknown():
        return;
      case AuthAuthenticated(:final user):
        likesCubit.userChanged(user.id);
      case AuthUnauthenticated():
        likesCubit.userChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (_, authState) => _syncUser(authState),
        ),
        BlocListener<LikesCubit, LikesState>(
          listenWhen: (previous, current) =>
              previous.failureCount != current.failureCount,
          listener: (context, state) {
            final failure = state.failure;
            if (failure is SessionFailure) {
              context.read<AuthCubit>().sessionExpired();
              context.showErrorSnackBar(failure.message);
              return;
            }
            context.showErrorSnackBar(LikeTexts.toggleFailed);
          },
        ),
      ],
      child: widget.child,
    );
  }
}
