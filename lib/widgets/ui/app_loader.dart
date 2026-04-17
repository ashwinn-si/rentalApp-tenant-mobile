import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.fullScreen = false});

  final bool fullScreen;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRipple(double phase) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + phase) % 1;
        final scale = 0.25 + (t * 1.45);
        final opacity = (1 - t).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet.withOpacity(0.20 * opacity),
              border: Border.all(
                color: AppColors.violet.withOpacity(0.60 * opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoaderContent() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildRipple(0.0),
          _buildRipple(0.5),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: AppColors.violet,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      return Scaffold(body: Center(child: _buildLoaderContent()));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _buildLoaderContent(),
      ),
    );
  }
}
