import 'package:flutter/material.dart';

// App version (from pubspec.yaml)
// Format: versionNumber+buildNumber (e.g., 1.0.0+1)
const String appVersion = '1.0.0';
const int appBuildNumber = 1;

// Store URLs for force update
const String appStoreUrl =
    'https://play.google.com/store/apps/details?id=com.rentalapp.tenant';

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

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card([Color color = AppColors.violet]) => [
        BoxShadow(
          color: color.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: color.withOpacity(0.03),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.violet);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.screenBg,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.violet,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.violet.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: AppColors.violet.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(
          color: AppColors.violet,
          width: 2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.55),
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
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
