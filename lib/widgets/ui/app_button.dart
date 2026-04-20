import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.useSolidBackground = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final bool useSolidBackground;

  Color _withLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final next = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(next).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = backgroundColor ?? AppColors.violet;
    final hasCustomColor = backgroundColor != null;
    final gradientColors = hasCustomColor
        ? <Color>[
            _withLightness(primaryColor, 0.06),
            _withLightness(primaryColor, -0.08),
          ]
        : <Color>[
            primaryColor,
            AppColors.violetDark,
          ];
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: useSolidBackground ? primaryColor : null,
        gradient: useSolidBackground
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
        ),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
