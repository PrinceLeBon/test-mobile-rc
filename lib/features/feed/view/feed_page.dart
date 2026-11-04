import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_tonal_button.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/account_sheet.dart';
import '../../auth/view/auth_navigation.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  static const String title = 'Blog';

  @override
  Widget build(BuildContext context) {
    final background = context.colorScheme.surfaceContainerLow;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        centerTitle: false,
        titleSpacing: AppSpacing.feedHorizontal,
        title: Row(
          children: [
            AppLogo(ringColor: background),
            const SizedBox(width: AppSpacing.sm),
            const Flexible(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FeedAccountAction(),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}

class FeedAccountAction extends StatelessWidget {
  const FeedAccountAction({super.key});

  static const String loginLabel = 'Se connecter';
  static const String accountTooltip = 'Mon compte';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: AppDurations.stateSwitch,
          switchInCurve: AppCurves.stateSwitch,
          child: switch (state) {
            AuthAuthenticated(:final user) => IconButton(
              key: const ValueKey('compte'),
              tooltip: accountTooltip,
              onPressed: () => showAccountSheet(context, user),
              icon: UserAvatar(
                username: user.username,
                size: AvatarSize.appBar,
              ),
            ),
            AuthUnauthenticated() => AppTonalButton(
              key: const ValueKey('visiteur'),
              label: loginLabel,
              icon: Icons.login_rounded,
              height: AppSizes.compactButtonHeight,
              onPressed: context.openLogin,
            ),
            AuthUnknown() => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}
