import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    this.fullScreen = false,
    this.showLabel = false,
    this.label = 'Loading',
  });

  final bool fullScreen;
  final bool showLabel;
  final String label;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleCurve;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scaleCurve = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildLoaderContent({required bool isDark}) {
    final trackOpacity = isDark ? 0.25 : 0.12;
    final shimmerPeak = isDark ? 0.95 : 0.8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced loader animation
        ScaleTransition(
          scale: _scaleCurve,
          child: SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background glow effect
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final pulseScale = 1.0 + 0.3 * _pulseController.value;
                    return Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.violet.withValues(alpha: 0.08),
                        ),
                      ),
                    );
                  },
                ),
                // Outer shimmer ring
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    return Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          startAngle: _shimmerController.value * 2 * math.pi,
                          endAngle: (_shimmerController.value + 0.25) * 2 * math.pi,
                          colors: [
                            AppColors.violet.withValues(alpha: 0.0),
                            AppColors.violet.withValues(alpha: shimmerPeak),
                            AppColors.violet.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Track ring
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.violet.withValues(alpha: trackOpacity),
                      width: 2.5,
                    ),
                  ),
                ),
                // Orbiting dot with trail effect
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, _) {
                    final angle = _orbitController.value * 2 * math.pi;
                    const radius = 44.0;
                    final dx = math.cos(angle) * radius;
                    final dy = math.sin(angle) * radius;

                    // Create trail effect with multiple dots
                    final positions = <Offset>[];
                    for (int i = 0; i < 3; i++) {
                      final trailAngle = angle - (i * 0.3);
                      final trailDx = math.cos(trailAngle) * radius;
                      final trailDy = math.sin(trailAngle) * radius;
                      positions.add(Offset(trailDx, trailDy));
                    }

                    return Stack(
                      children: [
                        // Trail dots
                        for (int i = 1; i < positions.length; i++)
                          Transform.translate(
                            offset: positions[i],
                            child: Container(
                              width: 8 - (i * 2).toDouble(),
                              height: 8 - (i * 2).toDouble(),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.violet.withValues(
                                  alpha: 0.3 * (1 - i / positions.length),
                                ),
                              ),
                            ),
                          ),
                        // Main orbiting dot
                        Transform.translate(
                          offset: Offset(dx, dy),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.violet,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.violet.withValues(alpha: 0.7),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Center pulsing dot
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = 0.8 + 0.2 * _pulseController.value;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.violet,
                              AppColors.violet.withValues(alpha: 0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.violet.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Loading text (optional)
        if (widget.showLabel) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.fullScreen) {
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
          child: Center(
            child: SingleChildScrollView(
              child: _buildLoaderContent(isDark: isDark),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _buildLoaderContent(isDark: isDark),
      ),
    );
  }
}
