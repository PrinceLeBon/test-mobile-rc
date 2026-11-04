import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/app_user.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../cubit/auth_cubit.dart';

Future<void> showAccountSheet(BuildContext context, AppUser user) {
  final authCubit = context.read<AuthCubit>();
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => AccountSheet(
      user: user,
      onLogOut: () {
        Navigator.of(sheetContext).pop();
        authCubit.logOut();
      },
    ),
  );
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key, required this.user, required this.onLogOut});

  static const String logOutLabel = 'Se déconnecter';

  final AppUser user;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final email = user.email;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxs,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  UserAvatar(username: user.username, size: AvatarSize.sheet),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email != null && email.isNotEmpty)
                          Text(
                            email,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: onLogOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.sheetTileHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: scheme.error),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        logOutLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
