import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class AppearAnimation extends StatefulWidget {
  const AppearAnimation({super.key, required this.child});

  static const double slideDistance = 8;

  final Widget child;

  @override
  State<AppearAnimation> createState() => _AppearAnimationState();
}

class _AppearAnimationState extends State<AppearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.appear,
  )..forward();

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.appear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _progress.value,
          child: Transform.translate(
            offset: Offset(
              0,
              AppearAnimation.slideDistance * (1 - _progress.value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
