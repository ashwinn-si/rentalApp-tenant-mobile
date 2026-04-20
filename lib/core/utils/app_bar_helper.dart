import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_tokens.dart';

AppBar buildPremiumAppBar({
  required String title,
  List<Widget>? actions,
  bool centerTitle = false,
}) {
  return AppBar(
    toolbarHeight: 72,
    titleSpacing: AppSpacing.md,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 38 / 2,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    centerTitle: centerTitle,
    backgroundColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    actionsIconTheme: const IconThemeData(
      color: Colors.white,
      size: 22,
    ),
    flexibleSpace: DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.violet,
                  AppColors.violetDark,
                ],
              ),
            ),
          ),
          Positioned(
            top: -34,
            right: -26,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -18,
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    ),
    shadowColor: Colors.transparent,
    actions: actions,
  );
}
