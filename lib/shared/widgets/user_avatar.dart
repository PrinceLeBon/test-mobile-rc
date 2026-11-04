import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

enum AvatarSize {
  comment(AppSizes.avatarComment, 13),
  appBar(AppSizes.avatarAppBar, 14),
  card(AppSizes.avatarCard, 16),
  detail(AppSizes.avatarDetail, 17),
  sheet(AppSizes.avatarSheet, 22);

  const AvatarSize(this.diameter, this.initialFontSize);

  final double diameter;
  final double initialFontSize;
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.username,
    this.size = AvatarSize.card,
  });

  static const int paletteLength = 8;

  final String username;
  final AvatarSize size;

  static int paletteIndexFor(String username) {
    final hash = username.codeUnits.fold<int>(
      0,
      (hash, unit) => (hash * 31 + unit) & 0x7fffffff,
    );
    return hash % paletteLength;
  }

  static String initialOf(String username) {
    final trimmedName = username.trim();
    if (trimmedName.isEmpty) {
      return '?';
    }
    return String.fromCharCode(trimmedName.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors.avatars[paletteIndexFor(username)];

    return ExcludeSemantics(
      child: Container(
        width: size.diameter,
        height: size.diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.background,
          shape: BoxShape.circle,
        ),
        child: Text(
          initialOf(username),
          style: TextStyle(
            color: palette.initial,
            fontSize: size.initialFontSize,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
