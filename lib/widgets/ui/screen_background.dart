import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    required this.child,
    super.key,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const <Color>[
                  Color(0xFF141223),
                  Color(0xFF100E1A),
                  Color(0xFF0C0B14),
                ]
              : const <Color>[
                  AppColors.bgGradient1,
                  AppColors.screenBg,
                  AppColors.bgGradient3,
                ],
          stops: const <double>[
            0.0,
            0.35,
            1.0,
          ],
        ),
      ),
      child: padding == null
          ? child
          : Padding(
              padding: padding!,
              child: child,
            ),
    );
  }
}
