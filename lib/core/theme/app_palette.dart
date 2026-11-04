import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color primary = Color(0xFF1F74B0);
  static const Color brand = Color(0xFF2B8AC9);
  static const Color brandGreen = Color(0xFF80B500);
  static const Color greenText = Color(0xFF3F6300);
  static const Color greenContainer = Color(0xFFEEF7DA);
  static const Color title = Color(0xFF000B72);
  static const Color lightBlue = Color(0xFFE5F3FC);
  static const Color error = Color(0xFFD7153B);
  static const Color errorContainer = Color(0xFFFDE7EB);
  static const Color onErrorContainer = Color(0xFF8C0B24);
  static const Color white = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A2240);
  static const Color textSecondary = Color(0xFF5B6478);
  static const Color textDisabled = Color(0xFF9AA3B5);
  static const Color feedBackground = Color(0xFFF5F9FD);
  static const Color surfaceContainer = Color(0xFFEEF3F9);
  static const Color surfaceContainerHigh = Color(0xFFE8EEF5);
  static const Color surfaceContainerHighest = Color(0xFFE3EAF2);
  static const Color outline = Color(0xFF7D8AA0);
  static const Color outlineVariant = Color(0xFFDCE4EE);
  static const Color inversePrimary = Color(0xFF8CC8F0);
  static const Color scrim = Color(0xFF0A1132);
  static const Color scrimOverlay = Color(0x730A1132);
  static const Color liked = Color(0xFFC8143F);
  static const Color likedContainer = Color(0xFFFDE8EE);
  static const Color skeletonBase = Color(0xFFE3EAF2);
  static const Color skeletonHighlight = Color(0xFFF1F5FA);
  static const Color snackBarErrorIcon = Color(0xFFFF8A9F);
  static const Color cardShadowNear = Color(0x0A000B72);
  static const Color cardShadowFar = Color(0x0F000B72);
  static const Color fabShadow = Color(0x521F74B0);
  static const Color commentBarShadow = Color(0x0F000B72);
  static const Color dialogShadow = Color(0x2E000B72);

  static const List<AvatarColors> avatars = [
    AvatarColors(background: Color(0xFFDCEEFB), initial: Color(0xFF1A5F8F)),
    AvatarColors(background: Color(0xFFE8F3D2), initial: Color(0xFF3F6300)),
    AvatarColors(background: Color(0xFFFDE7D9), initial: Color(0xFF9A3D0B)),
    AvatarColors(background: Color(0xFFEDE4FB), initial: Color(0xFF5B2EA6)),
    AvatarColors(background: Color(0xFFFBE3EC), initial: Color(0xFFA3164B)),
    AvatarColors(background: Color(0xFFD8F2EE), initial: Color(0xFF0F6B5E)),
    AvatarColors(background: Color(0xFFFCF1CF), initial: Color(0xFF7A5300)),
    AvatarColors(background: Color(0xFFE3E6F8), initial: Color(0xFF000B72)),
  ];
}

@immutable
class AvatarColors {
  const AvatarColors({required this.background, required this.initial});

  final Color background;
  final Color initial;
}
