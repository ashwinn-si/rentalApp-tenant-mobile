import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static Curve easeOutCubic = const Cubic(0.215, 0.61, 0.355, 1.0);
  static Curve easeInOutCubic = const Cubic(0.645, 0.045, 0.355, 1.0);
  static Curve easeOutExpo = const Cubic(0.19, 1.0, 0.22, 1.0);
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
    return _DelayedTweenAnimation(
      begin: 0.0,
      end: 1.0,
      delay: delay,
      duration: duration,
      curve: AppAnimations.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: animatedChild,
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
    return _DelayedTweenAnimation(
      begin: 0.8,
      end: 1.0,
      delay: delay,
      duration: duration,
      curve: AppAnimations.easeOutExpo,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: animatedChild),
        );
      },
      child: child,
    );
  }
}

class StaggeredListView extends StatelessWidget {
  const StaggeredListView({
    required this.children,
    super.key,
    this.stagger = const Duration(milliseconds: 70),
    this.duration = AppAnimations.normal,
  });

  final List<Widget> children;
  final Duration stagger;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideTransition(
              delay: Duration(milliseconds: stagger.inMilliseconds * entry.key),
              duration: duration,
              child: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class RouteFadeSlideTransition extends StatelessWidget {
  const RouteFadeSlideTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.easeOutCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _DelayedTweenAnimation extends StatefulWidget {
  const _DelayedTweenAnimation({
    required this.begin,
    required this.end,
    required this.duration,
    required this.curve,
    required this.builder,
    required this.child,
    this.delay = Duration.zero,
  });

  final double begin;
  final double end;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget child;
  final Widget Function(BuildContext, double, Widget?) builder;

  @override
  State<_DelayedTweenAnimation> createState() => _DelayedTweenAnimationState();
}

class _DelayedTweenAnimationState extends State<_DelayedTweenAnimation> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    _trigger();
  }

  @override
  void didUpdateWidget(covariant _DelayedTweenAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay ||
        oldWidget.begin != widget.begin ||
        oldWidget.end != widget.end) {
      _trigger();
    }
  }

  Future<void> _trigger() async {
    setState(() => _start = false);
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
    }
    setState(() => _start = true);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: widget.begin,
        end: _start ? widget.end : widget.begin,
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: widget.builder,
      child: widget.child,
    );
  }
}

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
