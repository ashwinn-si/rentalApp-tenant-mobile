import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.md),
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
