import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.fullScreen = false});

  final bool fullScreen;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildLoaderContent() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer shimmer ring
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) {
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: _shimmerController.value * 2 * math.pi,
                    endAngle: (_shimmerController.value + 1) * 2 * math.pi,
                    colors: [
                      AppColors.violet.withValues(alpha: 0.0),
                      AppColors.violet.withValues(alpha: 0.7),
                      AppColors.violet.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                ),
              );
            },
          ),
          // Track ring
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.violet.withValues(alpha: 0.12),
                width: 2,
              ),
            ),
          ),
          // Orbiting dot
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              final angle = _orbitController.value * 2 * math.pi;
              const radius = 33.0;
              final dx = math.cos(angle) * radius;
              final dy = math.sin(angle) * radius;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violet,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Center pulsing dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = 0.85 + 0.15 * _pulseController.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppColors.violet,
                        AppColors.violetDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF111827), Color(0xFF1F2937)]
                  : const [AppColors.screenBg, Colors.white],
            ),
          ),
          child: Center(child: _buildLoaderContent()),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _buildLoaderContent(),
      ),
    );
  }
}
