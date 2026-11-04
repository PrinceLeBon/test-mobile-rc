import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppLogoSize {
  small(
    side: 32,
    radius: 10,
    letterSize: 18,
    dotSize: 10,
    dotOffset: -3,
    ringWidth: 2,
  ),
  large(
    side: 56,
    radius: 16,
    letterSize: 30,
    dotSize: 16,
    dotOffset: -4,
    ringWidth: 3,
  );

  const AppLogoSize({
    required this.side,
    required this.radius,
    required this.letterSize,
    required this.dotSize,
    required this.dotOffset,
    required this.ringWidth,
  });

  final double side;
  final double radius;
  final double letterSize;
  final double dotSize;
  final double dotOffset;
  final double ringWidth;
}

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppLogoSize.small,
    required this.ringColor,
  });

  final AppLogoSize size;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size.side,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(size.radius),
                ),
                child: Center(
                  child: Text(
                    'b',
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontSize: size.letterSize,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.dotOffset,
              right: size.dotOffset,
              child: Container(
                width: size.dotSize,
                height: size.dotSize,
                decoration: BoxDecoration(
                  color: colors.brandGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: size.ringWidth,
                    strokeAlign: BorderSide.strokeAlignOutside,
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
