import 'package:flutter/material.dart';

// App version (from pubspec.yaml)
// Format: versionNumber+buildNumber (e.g., 1.0.0+1)
const String appVersion = '1.0.0';
const int appBuildNumber = 1;

// Store URLs for force update
const String appStoreUrl = 'https://play.google.com/store/apps/details?id=com.rentalapp.tenant';

class AppColors {
  AppColors._();

  static const violet = Color(0xFF7C3AED);
  static const paid = Color(0xFF16A34A);
  static const partial = Color(0xFFD97706);
  static const pending = Color(0xFFDC2626);
  static const screenBg = Color(0xFFF5F3FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  // Login page colors
  static const violetDark = Color(0xFF6D28D9);
  static const accentWarm = Color(0xFFF97316);
  static const bgGradient1 = Color(0xFFF9F5FF);
  static const bgGradient2 = Color(0xFFEDE9FE);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();

  static const double md = 12;
  static const double lg = 16;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet),
    scaffoldBackgroundColor: AppColors.screenBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.violet,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
  );
}
