import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.fullScreen = false});

  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    const spinner = CircularProgressIndicator(color: AppColors.violet);
    if (fullScreen) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.violet)));
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: spinner,
      ),
    );
  }
}
