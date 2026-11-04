import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_text_theme.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: AppPalette.white,
    primaryContainer: AppPalette.lightBlue,
    onPrimaryContainer: AppPalette.title,
    secondary: AppPalette.brandGreen,
    onSecondary: AppPalette.title,
    secondaryContainer: AppPalette.greenContainer,
    onSecondaryContainer: AppPalette.greenText,
    tertiary: AppPalette.brandGreen,
    onTertiary: AppPalette.title,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
    surface: AppPalette.white,
    onSurface: AppPalette.text,
    onSurfaceVariant: AppPalette.textSecondary,
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: AppPalette.feedBackground,
    surfaceContainer: AppPalette.surfaceContainer,
    surfaceContainerHigh: AppPalette.surfaceContainerHigh,
    surfaceContainerHighest: AppPalette.surfaceContainerHighest,
    outline: AppPalette.outline,
    outlineVariant: AppPalette.outlineVariant,
    inverseSurface: AppPalette.text,
    onInverseSurface: AppPalette.white,
    inversePrimary: AppPalette.inversePrimary,
    shadow: AppPalette.title,
    scrim: AppPalette.scrim,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get light {
    const scheme = colorScheme;
    const text = AppTextTheme.light;
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    final disabledBackground = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled)
          ? scheme.surfaceContainerHighest
          : null,
    );
    final disabledForeground = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled)
          ? AppPalette.textDisabled
          : null,
    );
    OutlineInputBorder fieldBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      splashFactory: InkRipple.splashFactory,
      splashColor: scheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      extensions: const [AppColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSizes.secondaryButtonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: disabledBackground,
          foregroundColor: disabledForeground,
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSizes.secondaryButtonHeight),
          ),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.disabled)
                ? AppPalette.textDisabled
                : scheme.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSizes.fieldVerticalPadding,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        helperStyle: text.bodySmall,
        counterStyle: text.labelSmall,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: fieldBorder(scheme.outline, 1),
        enabledBorder: fieldBorder(scheme.outline, 1),
        disabledBorder: fieldBorder(scheme.outlineVariant, 1),
        focusedBorder: fieldBorder(AppPalette.brand, 2),
        errorBorder: fieldBorder(scheme.error, 2),
        focusedErrorBorder: fieldBorder(scheme.error, 2),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppPalette.brand,
        selectionHandleColor: AppPalette.brand,
        selectionColor: AppPalette.brand.withValues(alpha: 0.25),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: text.labelLarge,
        extendedSizeConstraints: const BoxConstraints.tightFor(
          height: AppSizes.fabHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: AppPalette.scrimOverlay,
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        modalBarrierColor: AppPalette.scrimOverlay,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        dragHandleSize: const Size(
          AppSizes.sheetHandleWidth,
          AppSizes.sheetHandleHeight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.brand,
        strokeWidth: AppSizes.progressStroke,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    );
  }
}
