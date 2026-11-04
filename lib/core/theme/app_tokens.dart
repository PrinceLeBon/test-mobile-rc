import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double iconGap = 6;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  static const double feedHorizontal = md;
  static const double detailHorizontal = lg;
  static const double authHorizontal = xl;
  static const double feedTop = xxs;
  static const double feedBottom = 96;
  static const double feedCardGap = sm;
  static const double labelToField = xs;
  static const double betweenFields = lg;
  static const double beforePrimaryButton = xl;
  static const double headerToFirstField = xxl;
}

abstract final class AppRadius {
  static const double small = 6;
  static const double medium = 12;
  static const double control = 14;
  static const double fab = 18;
  static const double card = 20;
  static const double dialog = 24;
  static const double sheet = 28;
  static const double full = 999;
}

abstract final class AppSizes {
  static const double primaryButtonHeight = 52;
  static const double secondaryButtonHeight = 48;
  static const double compactButtonHeight = 40;
  static const double fieldHeight = 52;
  static const double fieldVerticalPadding = 14;
  static const double fabHeight = 56;
  static const double chipHeight = 34;
  static const double minTouchTarget = 48;
  static const double commentFieldMinHeight = 44;
  static const double sendButton = 44;
  static const double statusCircle = 64;
  static const double statusIcon = 28;
  static const double statusMaxWidth = 280;
  static const double buttonProgress = 20;
  static const double pageProgress = 24;
  static const double progressStroke = 2.4;
  static const double fieldIcon = 20;
  static const double chipIcon = 18;
  static const double logo = 32;
  static const double logoDot = 10;
  static const double logoRadius = 10;
  static const double authGradientHeight = 320;
  static const double sheetHandleWidth = 36;
  static const double sheetHandleHeight = 4;
  static const double sheetTileHeight = 56;
  static const double avatarComment = 32;
  static const double avatarAppBar = 36;
  static const double avatarCard = 40;
  static const double avatarDetail = 44;
  static const double avatarSheet = 56;
}

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppPalette.cardShadowNear,
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: AppPalette.cardShadowFar,
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
  ];
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: AppPalette.fabShadow,
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
  static const List<BoxShadow> commentBar = [
    BoxShadow(
      color: AppPalette.commentBarShadow,
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: AppPalette.dialogShadow,
      offset: Offset(0, 16),
      blurRadius: 48,
    ),
  ];
}

abstract final class AppDurations {
  static const Duration like = Duration(milliseconds: 300);
  static const Duration likeColor = Duration(milliseconds: 150);
  static const Duration appear = Duration(milliseconds: 220);
  static const Duration newCommentHighlight = Duration(milliseconds: 1200);
  static const Duration skeletonPulse = Duration(milliseconds: 900);
  static const Duration stateSwitch = Duration(milliseconds: 200);
  static const Duration snackBar = Duration(seconds: 4);
}

abstract final class AppCurves {
  static const Curve like = Curves.easeOutBack;
  static const Curve likeColor = Curves.easeOut;
  static const Curve appear = Curves.easeOutCubic;
  static const Curve newCommentHighlight = Curves.easeOut;
  static const Curve skeletonPulse = Curves.easeInOut;
  static const Curve stateSwitch = Curves.easeOut;
}
