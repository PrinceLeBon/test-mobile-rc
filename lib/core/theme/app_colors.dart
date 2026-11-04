import 'package:flutter/material.dart';

import 'app_palette.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.brandGreen,
    required this.title,
    required this.textDisabled,
    required this.liked,
    required this.likedContainer,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.snackBarErrorIcon,
    required this.avatars,
  });

  static const AppColors light = AppColors(
    brand: AppPalette.brand,
    brandGreen: AppPalette.brandGreen,
    title: AppPalette.title,
    textDisabled: AppPalette.textDisabled,
    liked: AppPalette.liked,
    likedContainer: AppPalette.likedContainer,
    skeletonBase: AppPalette.skeletonBase,
    skeletonHighlight: AppPalette.skeletonHighlight,
    snackBarErrorIcon: AppPalette.snackBarErrorIcon,
    avatars: AppPalette.avatars,
  );

  final Color brand;
  final Color brandGreen;
  final Color title;
  final Color textDisabled;
  final Color liked;
  final Color likedContainer;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color snackBarErrorIcon;
  final List<AvatarColors> avatars;

  @override
  AppColors copyWith({
    Color? brand,
    Color? brandGreen,
    Color? title,
    Color? textDisabled,
    Color? liked,
    Color? likedContainer,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? snackBarErrorIcon,
    List<AvatarColors>? avatars,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      brandGreen: brandGreen ?? this.brandGreen,
      title: title ?? this.title,
      textDisabled: textDisabled ?? this.textDisabled,
      liked: liked ?? this.liked,
      likedContainer: likedContainer ?? this.likedContainer,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      snackBarErrorIcon: snackBarErrorIcon ?? this.snackBarErrorIcon,
      avatars: avatars ?? this.avatars,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandGreen: Color.lerp(brandGreen, other.brandGreen, t)!,
      title: Color.lerp(title, other.title, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      liked: Color.lerp(liked, other.liked, t)!,
      likedContainer: Color.lerp(likedContainer, other.likedContainer, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      snackBarErrorIcon: Color.lerp(
        snackBarErrorIcon,
        other.snackBarErrorIcon,
        t,
      )!,
      avatars: t < 0.5 ? avatars : other.avatars,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
