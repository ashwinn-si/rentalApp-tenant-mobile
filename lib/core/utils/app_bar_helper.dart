import 'package:flutter/material.dart';

import '../constants/app_tokens.dart';

AppBar buildPremiumAppBar({
  required String title,
  List<Widget>? actions,
  bool centerTitle = false,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    centerTitle: centerTitle,
    backgroundColor: AppColors.violet,
    elevation: 4,
    shadowColor: AppColors.violet.withOpacity(0.3),
    actions: actions,
  );
}
