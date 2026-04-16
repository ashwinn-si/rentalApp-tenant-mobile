import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static Curve easeOutCubic = Cubic(0.215, 0.61, 0.355, 1.0);
  static Curve easeInOutCubic = Cubic(0.645, 0.045, 0.355, 1.0);
  static Curve easeOutExpo = Cubic(0.19, 1.0, 0.22, 1.0);
}

class FadeSlideTransition extends StatelessWidget {
  const FadeSlideTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 0),
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AppAnimations.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ScaleInAnimation extends StatelessWidget {
  const ScaleInAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 0),
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration,
      curve: AppAnimations.easeOutExpo,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}

// Note: For staggered list animations, use the pattern below in your widgets:
// for (int i = 0; i < items.length; i++) {
//   TweenAnimationBuilder<double>(
//     tween: Tween(begin: 0.0, end: 1.0),
//     duration: AppAnimations.normal,
//     delay: Duration(milliseconds: 50 * i), // Will be ignored by TweenAnimationBuilder
//     curve: AppAnimations.easeOutCubic,
//     builder: (context, value, child) {
//       return Opacity(opacity: value, child: child);
//     },
//     child: itemWidget,
//   )
// }
//
// Alternatively, wrap in an AnimationDelay widget or handle stagger in controller

class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AppAnimations.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: AppAnimations.slow,
        );
}
