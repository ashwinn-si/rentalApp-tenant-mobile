# Tenant Portal — Flutter Implementation Guide

> Cross-platform (iOS + Android) rebuild of `tenant.app.com`  
> with clean architecture in Dart.

---

## Table of Contents

1. [Tech Stack & Rationale](#1-tech-stack--rationale)
2. [Project Setup](#2-project-setup)
3. [Project Structure](#3-project-structure)
4. [Design System & Tokens](#4-design-system--tokens)
5. [Generic API Helper (Dio)](#5-generic-api-helper-dio)
6. [State Management (Riverpod)](#6-state-management-riverpod)
7. [Reusable Widgets](#7-reusable-widgets)
    - 7.1 [AppLoader](#71-apploader)
    - 7.2 [AppToast (SnackBar service)](#72-apptoast)
    - 7.3 [AppModal](#73-appmodal)
    - 7.4 [AppBottomSheet](#74-appbottomsheet)
    - 7.5 [DataTable](#75-datatable-widget)
    - 7.6 [Charts (Bar + Line)](#76-charts)
    - 7.7 [StatusChip](#77-statuschip)
    - 7.8 [InfoField](#78-infofield)
    - 7.9 [StateCard](#79-statecard)
    - 7.10 [AppButton](#710-appbutton)
    - 7.11 [AppTextField + FormField](#711-apptextfield--formfield)
    - 7.12 [SkeletonCard](#712-skeletoncard)
    - 7.13 [FlatSelector](#713-flatselector)
    - 7.14 [RentBreakdownCard](#714-rentbreakdowncard)
    - 7.15 [NotificationCard](#715-notificationcard)
    - 7.16 [SimplePaginator](#716-simplepaginator)
8. [Navigation (go_router)](#8-navigation-go_router)
9. [Authentication Flow](#9-authentication-flow)
10. [Screens](#10-screens)
    - 10.1 [Login](#101-login-screen)
    - 10.2 [Change Password](#102-change-password-screen)
    - 10.3 [Dashboard](#103-dashboard-screen)
    - 10.4 [History](#104-history-screen)
    - 10.5 [Notifications](#105-notifications-screen)
    - 10.6 [Documents](#106-documents-screen)
    - 10.7 [Profile](#107-profile-screen)
11. [Backend API Contracts](#11-backend-api-contracts)
12. [Environment & Config](#12-environment--config)
13. [Testing Checklist](#13-testing-checklist)

---

## 1. Tech Stack & Rationale

| Concern              | Library / Tool                                  | Why                                                    |
| -------------------- | ----------------------------------------------- | ------------------------------------------------------ |
| Framework            | **Flutter 3.22+**                               | Single codebase, iOS + Android + Web                   |
| Language             | **Dart 3.4** (sound null safety)                | Compiled AOT, fast UI rendering                        |
| Navigation           | **go_router 14**                                | Declarative, deep-link ready, guard support            |
| State                | **Riverpod 2** (code gen)                       | Compile-safe providers, async state built-in           |
| HTTP                 | **Dio 5**                                       | Interceptors, cancel tokens, same pattern as Axios     |
| Forms                | **reactive_forms**                              | Type-safe form groups, validators, mirrors zod pattern |
| Charts               | **fl_chart 0.68**                               | Bar + Line charts, highly customizable                 |
| Secure Storage       | **flutter_secure_storage**                      | Keychain (iOS) / Keystore (Android) for token          |
| Persistent State     | **shared_preferences**                          | Auth state persistence across restarts                 |
| Toast / Snackbar     | **fluttertoast** + custom SnackBar service      | Cross-platform toast positioned at bottom              |
| Bottom Sheet         | Built-in `showModalBottomSheet` + custom widget | No extra dep needed in Flutter                         |
| Documents            | **url_launcher** + **dio** (download)           | Open pre-signed S3 URLs in browser                     |
| Animations           | **shimmer**                                     | Skeleton loading cards                                 |
| Gradients            | Built-in `LinearGradient`                       | No extra dep needed                                    |
| Icons                | **Material Icons** + **lucide_icons**           | Matches Lucide from web                                |
| Env Config           | **flutter_dotenv**                              | `.env` file support per flavor                         |
| Dependency Injection | **Riverpod** (via providers)                    | No separate DI container needed                        |
| Date Formatting      | **intl**                                        | `DateFormat`, `NumberFormat` — replaces date-fns       |

---

## 2. Project Setup

### 2.1 Create Flutter Project

```bash
# Create project
flutter create tenant_portal --org com.yourcompany --platforms ios,android
cd tenant_portal

# Verify Flutter version
flutter --version  # Should be 3.22+
```

### 2.2 `pubspec.yaml`

```yaml
name: tenant_portal
description: Tenant Portal Mobile App
version: 1.0.0+1

environment:
    sdk: '>=3.4.0 <4.0.0'

dependencies:
    flutter:
        sdk: flutter

    # Navigation
    go_router: ^14.2.0

    # State Management
    flutter_riverpod: ^2.5.1
    riverpod_annotation: ^2.3.5

    # HTTP
    dio: ^5.4.3
    pretty_dio_logger: ^1.3.1

    # Forms
    reactive_forms: ^17.0.0

    # Storage
    flutter_secure_storage: ^9.2.2
    shared_preferences: ^2.3.1

    # Charts
    fl_chart: ^0.68.0

    # Toast
    fluttertoast: ^8.2.8

    # Documents / URL
    url_launcher: ^6.3.0

    # Shimmer skeleton
    shimmer: ^3.0.0

    # Animations
    flutter_animate: ^4.5.0

    # Icons
    lucide_icons: ^0.0.4

    # Env
    flutter_dotenv: ^5.1.0

    # Date/Number formatting
    intl: ^0.19.0

    # Misc
    equatable: ^2.0.5
    freezed_annotation: ^2.4.4
    json_annotation: ^4.9.0

dev_dependencies:
    flutter_test:
        sdk: flutter
    build_runner: ^2.4.11
    riverpod_generator: ^2.4.3
    freezed: ^2.5.3
    json_serializable: ^6.8.0
    flutter_lints: ^4.0.0
```

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod + Freezed + json_serializable)
dart run build_runner build --delete-conflicting-outputs
```

### 2.3 `android/app/build.gradle` — Flavors

```groovy
android {
  flavorDimensions "env"
  productFlavors {
    development {
      dimension "env"
      applicationIdSuffix ".dev"
      versionNameSuffix "-dev"
    }
    staging {
      dimension "env"
      applicationIdSuffix ".staging"
    }
    production {
      dimension "env"
    }
  }
}
```

---

## 3. Project Structure

```
tenant_portal/
├── lib/
│   ├── main.dart                     # Entry point — flavor + env bootstrap
│   ├── app.dart                      # MaterialApp + GoRouter + Riverpod scope
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_tokens.dart       # Design tokens (colors, spacing, radius)
│   │   ├── network/
│   │   │   ├── dio_client.dart       # Generic Dio instance + interceptors
│   │   │   └── api_response.dart     # Generic ApiResponse<T> wrapper
│   │   ├── storage/
│   │   │   └── secure_storage.dart   # Token read/write helpers
│   │   ├── router/
│   │   │   └── app_router.dart       # go_router config + guards
│   │   ├── services/
│   │   │   └── toast_service.dart    # Global toast/snackbar helper
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       ├── date_formatter.dart
│   │       └── pii_masker.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── models/
│   │   │   │       ├── login_request.dart
│   │   │   │       └── login_response.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       └── change_password_screen.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   ├── dashboard_repository.dart
│   │   │   │   └── models/
│   │   │   │       └── dashboard_response.dart
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   └── screens/
│   │   │       └── dashboard_screen.dart
│   │   │
│   │   ├── history/
│   │   │   ├── data/
│   │   │   ├── providers/
│   │   │   └── screens/
│   │   │       └── history_screen.dart
│   │   │
│   │   ├── notifications/
│   │   │   └── screens/
│   │   │       └── notifications_screen.dart
│   │   │
│   │   ├── documents/
│   │   │   ├── data/
│   │   │   ├── providers/
│   │   │   └── screens/
│   │   │       └── documents_screen.dart
│   │   │
│   │   └── profile/
│   │       ├── data/
│   │       └── screens/
│   │           └── profile_screen.dart
│   │
│   └── widgets/
│       ├── ui/                        # Generic reusable widgets
│       │   ├── app_loader.dart
│       │   ├── app_modal.dart
│       │   ├── app_bottom_sheet.dart
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   ├── data_table_widget.dart
│       │   ├── chart_widgets.dart
│       │   ├── status_chip.dart
│       │   ├── info_field.dart
│       │   ├── state_card.dart
│       │   └── skeleton_card.dart
│       └── domain/                    # Feature-specific widgets
│           ├── flat_selector.dart
│           ├── rent_breakdown_card.dart
│           ├── notification_card.dart
│           ├── simple_paginator.dart
│           └── payment_split_grid.dart
│
├── assets/
│   ├── images/
│   └── .env.development
│   └── .env.production
│
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 4. Design System & Tokens

```dart
// lib/core/constants/app_tokens.dart

import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const violet   = Color(0xFF7C3AED);
  static const fuchsia  = Color(0xFFA21CAF);
  static const rose     = Color(0xFFE11D48);

  // Status
  static const paid     = Color(0xFF16A34A);
  static const partial  = Color(0xFFD97706);
  static const pending  = Color(0xFFDC2626);

  // Notification gradients
  static const personalGradientStart   = Color(0xFF7C3AED);
  static const personalGradientEnd     = Color(0xFFA21CAF);
  static const apartmentGradientStart  = Color(0xFFD97706);
  static const apartmentGradientEnd    = Color(0xFFB45309);
  static const expiredGradientStart    = Color(0xFF6B7280);
  static const expiredGradientEnd      = Color(0xFF4B5563);

  // Backgrounds
  static const screenBg   = Color(0xFFF5F3FF);
  static const cardBg     = Color(0xFFFFFFFF);
  static const skeletonBg = Color(0xFFE5E7EB);

  // Text
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textInverse   = Color(0xFFFFFFFF);
}

// ─── Spacing ─────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ─── Border Radius ───────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double full = 999;

  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
}

// ─── Typography ──────────────────────────────────────────────────────────────

class AppText {
  AppText._();

  static const xs   = TextStyle(fontSize: 12);
  static const sm   = TextStyle(fontSize: 14);
  static const base = TextStyle(fontSize: 16);
  static const lg   = TextStyle(fontSize: 18);
  static const xl   = TextStyle(fontSize: 20);
  static const x2l  = TextStyle(fontSize: 24);
  static const x3l  = TextStyle(fontSize: 30);

  static TextStyle heading(double size) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: AppColors.textPrimary);

  static TextStyle label(double size) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

// ─── Shadows ─────────────────────────────────────────────────────────────────

class AppShadow {
  AppShadow._();
  static const card = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
}

// ─── Theme ───────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet),
    scaffoldBackgroundColor: AppColors.screenBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.violet,
      foregroundColor: AppColors.textInverse,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.violet,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardBg,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.violet, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.pending),
      ),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
```

---

## 5. Generic API Helper (Dio)

```dart
// lib/core/network/api_response.dart

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse({this.data, this.error, this.statusCode});

  bool get isSuccess => data != null && error == null;

  factory ApiResponse.success(T data, [int? statusCode]) =>
      ApiResponse(data: data, statusCode: statusCode);

  factory ApiResponse.failure(String error, [int? statusCode]) =>
      ApiResponse(error: error, statusCode: statusCode);
}
```

```dart
// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../services/toast_service.dart';
import 'api_response.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  // Navigator key for context-free navigation on 401
  static final navigatorKey = GlobalKey<NavigatorState>();

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment('API_URL',
            defaultValue: 'https://api.tenant.app.com'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      // Attach Bearer token
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await SecureStorageService.clearToken();
            // Navigate to login
            navigatorKey.currentContext?.go('/login');
            ToastService.showError('Session expired', 'Please log in again.');
          }
          handler.next(error);
        },
      ),
      // Pretty logging in debug mode
      if (const bool.fromEnvironment('FLUTTER_DEBUG', defaultValue: true))
        LogInterceptor(responseBody: true, requestBody: true),
    ]);
  }

  static DioClient get instance => _instance ??= DioClient._();

  // ─── Generic Request Wrapper ───────────────────────────────────────────────

  Future<ApiResponse<T>> request<T>({
    required String method,
    required String path,
    T Function(dynamic json)? fromJson,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        options: Options(method: method),
      );

      final parsed = fromJson != null ? fromJson(response.data) : response.data as T;
      return ApiResponse.success(parsed, response.statusCode);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'An unexpected error occurred';
      return ApiResponse.failure(message, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  // Convenience methods
  Future<ApiResponse<T>> get<T>(String path, {
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) =>
      request(method: 'GET', path: path, fromJson: fromJson,
          queryParams: queryParams, cancelToken: cancelToken);

  Future<ApiResponse<T>> post<T>(String path, {
    T Function(dynamic)? fromJson,
    Map<String, dynamic>? data,
  }) =>
      request(method: 'POST', path: path, fromJson: fromJson, data: data);
}
```

```dart
// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> setToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.deleteAll();

  static Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshKey);
}
```

### Endpoint Repositories

```dart
// lib/features/auth/data/auth_repository.dart

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

class AuthRepository {
  final _client = DioClient.instance;

  Future<ApiResponse<LoginResponse>> login(LoginRequest req) =>
      _client.post<LoginResponse>(
        '/tenant/auth/login',
        data: req.toJson(),
        fromJson: (json) => LoginResponse.fromJson(json),
      );

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _client.post(
        '/tenant/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        fromJson: (json) => json as Map<String, dynamic>,
      );
}
```

```dart
// lib/features/auth/data/models/login_response.dart
// (Use freezed + json_serializable for all models)

import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required LoginUser user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class LoginUser with _$LoginUser {
  const factory LoginUser({
    required String id,
    required String tenantKey,
    @Default(false) bool needsPasswordChange,
  }) = _LoginUser;

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);
}
```

---

## 6. State Management (Riverpod)

### Auth State

```dart
// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    String? token,
    String? userId,
    String? tenantKey,
    String? activeFlatId,
    @Default(false) bool mustChangePassword,
    @Default(false) bool isLoading,
    String? error,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  final _repo = AuthRepository();

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await SecureStorageService.getToken();
    if (token == null) return;

    state = state.copyWith(
      token: token,
      userId: prefs.getString('userId'),
      tenantKey: prefs.getString('tenantKey'),
      activeFlatId: prefs.getString('activeFlatId'),
      mustChangePassword: prefs.getBool('mustChangePassword') ?? false,
    );
  }

  Future<String?> login({
    required String clientCode,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repo.login(
      LoginRequest(clientCode: clientCode, email: email, password: password),
    );

    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, error: result.error);
      return result.error;
    }

    final loginData = result.data!;
    await _persist(loginData);
    state = state.copyWith(
      isLoading: false,
      token: loginData.accessToken,
      userId: loginData.user.id,
      tenantKey: loginData.user.tenantKey,
      mustChangePassword: loginData.user.needsPasswordChange,
    );
    return null; // null = success
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!result.isSuccess) {
      state = state.copyWith(isLoading: false, error: result.error);
      return result.error;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mustChangePassword', false);
    state = state.copyWith(isLoading: false, mustChangePassword: false);
    return null;
  }

  void setActiveFlatId(String flatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeFlatId', flatId);
    state = state.copyWith(activeFlatId: flatId);
  }

  Future<void> logout() async {
    await SecureStorageService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }

  Future<void> _persist(LoginResponse data) async {
    await SecureStorageService.setToken(data.accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', data.user.id);
    await prefs.setString('tenantKey', data.user.tenantKey);
    await prefs.setBool('mustChangePassword', data.user.needsPasswordChange);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience selector
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.token != null));
});
```

### Dashboard State (example Riverpod async provider)

```dart
// lib/features/dashboard/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_response.dart';
import '../../auth/providers/auth_provider.dart';

final dashboardProvider = FutureProvider.family<DashboardResponse, String?>(
  (ref, flatId) async {
    final repo = DashboardRepository();
    final result = await repo.getDashboard(flatId: flatId);
    if (!result.isSuccess) throw Exception(result.error);
    return result.data!;
  },
);

// Watch active flat and auto-refresh
final activeDashboardProvider = FutureProvider<DashboardResponse>((ref) {
  final flatId = ref.watch(authProvider.select((s) => s.activeFlatId));
  return ref.watch(dashboardProvider(flatId).future);
});
```

---

## 7. Reusable Widgets

### 7.1 AppLoader

```dart
// lib/widgets/ui/app_loader.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class AppLoader extends StatelessWidget {
  final bool fullScreen;
  final Color? color;

  const AppLoader({super.key, this.fullScreen = false, this.color});

  // Static helper — show overlay dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(color: AppColors.violet),
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final spinner = CircularProgressIndicator(
      color: color ?? AppColors.violet,
      strokeWidth: 3,
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.screenBg,
        body: Center(child: spinner),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: spinner,
      ),
    );
  }
}
```

### 7.2 AppToast

```dart
// lib/core/services/toast_service.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_tokens.dart';

class ToastService {
  ToastService._();

  static void showSuccess(String message, [String? detail]) {
    Fluttertoast.showToast(
      msg: detail != null ? '$message\n$detail' : message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.paid,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showError(String message, [String? detail]) {
    Fluttertoast.showToast(
      msg: detail != null ? '$message\n$detail' : message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.pending,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // SnackBar variant (needs BuildContext — preferred within screens)
  static void showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.pending : AppColors.paid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
```

### 7.3 AppModal

```dart
// lib/widgets/ui/app_modal.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class AppModalAction {
  final String label;
  final VoidCallback onPressed;
  final AppModalActionVariant variant;

  const AppModalAction({
    required this.label,
    required this.onPressed,
    this.variant = AppModalActionVariant.secondary,
  });
}

enum AppModalActionVariant { primary, secondary, danger }

class AppModal extends StatelessWidget {
  final String title;
  final Widget body;
  final List<AppModalAction> actions;

  const AppModal({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    List<AppModalAction> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppModal(title: title, body: body, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: AppText.heading(18)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: body,
              ),
            ),
            // Actions
            if (actions.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: actions.map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ActionButton(action: a),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final AppModalAction action;
  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = {
      AppModalActionVariant.primary:   AppColors.violet,
      AppModalActionVariant.secondary: const Color(0xFFF3F4F6),
      AppModalActionVariant.danger:    AppColors.pending,
    };
    final textColors = {
      AppModalActionVariant.primary:   Colors.white,
      AppModalActionVariant.secondary: AppColors.textPrimary,
      AppModalActionVariant.danger:    Colors.white,
    };
    return ElevatedButton(
      onPressed: action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors[action.variant],
        foregroundColor: textColors[action.variant],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      child: Text(action.label),
    );
  }
}
```

### 7.4 AppBottomSheet

```dart
// lib/widgets/ui/app_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetContent(title: title, child: child),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String? title;
  final Widget child;
  const _BottomSheetContent({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            // Title
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title!, style: AppText.heading(18)),
                ),
              ),
              const Divider(height: 1),
            ],
            // Content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [child],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7.5 DataTable Widget

```dart
// lib/widgets/ui/data_table_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class AppColumn<T> {
  final String key;
  final String header;
  final double width;
  final Alignment alignment;
  final Widget Function(dynamic value, T row)? cellBuilder;

  const AppColumn({
    required this.key,
    required this.header,
    this.width = 120,
    this.alignment = Alignment.centerLeft,
    this.cellBuilder,
  });
}

class AppDataTable<T> extends StatelessWidget {
  final List<AppColumn<T>> columns;
  final List<T> data;
  final String Function(T item) keyExtractor;
  final String emptyText;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.keyExtractor,
    this.emptyText = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(emptyText,
              style: AppText.sm.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Header
          _buildRow(
            children: columns.map((c) => SizedBox(
              width: c.width,
              child: Align(
                alignment: c.alignment,
                child: Text(c.header,
                    style: AppText.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet)),
              ),
            )).toList(),
            isHeader: true,
          ),
          // Rows
          ...data.asMap().entries.map((entry) {
            final isAlt = entry.key % 2 == 1;
            return _buildRow(
              isAlt: isAlt,
              children: columns.map((col) {
                final value = (entry.value as dynamic)[col.key];
                return SizedBox(
                  width: col.width,
                  child: col.cellBuilder != null
                      ? col.cellBuilder!(value, entry.value)
                      : Align(
                          alignment: col.alignment,
                          child: Text('${value ?? '-'}',
                              style: AppText.sm.copyWith(
                                  color: AppColors.textPrimary)),
                        ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow({
    required List<Widget> children,
    bool isHeader = false,
    bool isAlt = false,
  }) {
    return Container(
      color: isHeader
          ? const Color(0xFFF5F3FF)
          : isAlt
              ? const Color(0xFFFAFAFA)
              : Colors.white,
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: AppSpacing.sm),
      child: Row(children: children),
    );
  }
}
```

### 7.6 Charts

```dart
// lib/widgets/ui/chart_widgets.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/utils/currency_formatter.dart';

// ─── Stacked Bar Chart ────────────────────────────────────────────────────────

class RentStackedBarChart extends StatelessWidget {
  final List<RentBarItem> data;
  const RentStackedBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Rent Breakdown', style: AppText.label(16)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 260,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (data.length * 72.0).clamp(
                  MediaQuery.of(context).size.width - 32, double.infinity),
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value.baseRent + e.value.utility +
                            e.value.maintenance + e.value.previousDues).toDouble(),
                        rodStackItems: [
                          BarChartRodStackItem(0, e.value.baseRent.toDouble(),
                              const Color(0xFF7C3AED)),
                          BarChartRodStackItem(e.value.baseRent.toDouble(),
                              (e.value.baseRent + e.value.utility).toDouble(),
                              const Color(0xFF06B6D4)),
                          BarChartRodStackItem(
                              (e.value.baseRent + e.value.utility).toDouble(),
                              (e.value.baseRent + e.value.utility + e.value.maintenance).toDouble(),
                              const Color(0xFFF59E0B)),
                          BarChartRodStackItem(
                              (e.value.baseRent + e.value.utility + e.value.maintenance).toDouble(),
                              (e.value.baseRent + e.value.utility + e.value.maintenance + e.value.previousDues).toDouble(),
                              const Color(0xFFEF4444)),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        width: 40,
                      ),
                    ],
                  )).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          data[value.toInt()].monthLabel,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '₹${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 10),
                        ),
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ),
        ),
        _Legend(items: const [
          _LegendItem('Base Rent', Color(0xFF7C3AED)),
          _LegendItem('Utility', Color(0xFF06B6D4)),
          _LegendItem('Maintenance', Color(0xFFF59E0B)),
          _LegendItem('Previous Dues', Color(0xFFEF4444)),
        ]),
      ],
    );
  }
}

// ─── Line Chart ───────────────────────────────────────────────────────────────

class RentTrendLineChart extends StatelessWidget {
  final List<RentLineItem> data;
  const RentTrendLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    FlSpot toSpot(int i, num value) => FlSpot(i.toDouble(), value.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due vs Paid Trend', style: AppText.label(16)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (data.length * 72.0).clamp(
                  MediaQuery.of(context).size.width - 32, double.infinity),
              child: LineChart(LineChartData(
                lineBarsData: [
                  _line(data.asMap().entries.map((e) => toSpot(e.key, e.value.totalDue)).toList(),
                      const Color(0xFF7C3AED)),
                  _line(data.asMap().entries.map((e) => toSpot(e.key, e.value.paid)).toList(),
                      AppColors.paid),
                  _line(data.asMap().entries.map((e) => toSpot(e.key, e.value.pending)).toList(),
                      AppColors.pending, isDashed: true),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox();
                        return Text(data[i].monthLabel, style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '₹${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 10),
                      ),
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              )),
            ),
          ),
        ),
        _Legend(items: const [
          _LegendItem('Total Due', Color(0xFF7C3AED)),
          _LegendItem('Paid', AppColors.paid),
          _LegendItem('Pending', AppColors.pending),
        ]),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color, {bool isDashed = false}) =>
      LineChartBarData(
        spots: spots,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        dashArray: isDashed ? [4, 4] : null,
      );
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class RentBarItem {
  final String monthLabel;
  final num baseRent, utility, maintenance, previousDues;
  const RentBarItem({
    required this.monthLabel,
    required this.baseRent,
    required this.utility,
    required this.maintenance,
    required this.previousDues,
  });
}

class RentLineItem {
  final String monthLabel;
  final num totalDue, paid, pending;
  const RentLineItem({
    required this.monthLabel,
    required this.totalDue,
    required this.paid,
    required this.pending,
  });
}

// ─── Legend ──────────────────────────────────────────────────────────────────

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
}

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;
  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(
            color: item.color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(item.label,
              style: AppText.xs.copyWith(color: AppColors.textSecondary)),
        ],
      )).toList(),
    );
  }
}
```

### 7.7 StatusChip

```dart
// lib/widgets/ui/status_chip.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

enum RentStatus { paid, partial, pending }

class StatusChip extends StatelessWidget {
  final RentStatus status;

  const StatusChip({super.key, required this.status});

  factory StatusChip.fromString(String s) {
    return StatusChip(
      status: switch (s.toLowerCase()) {
        'paid'    => RentStatus.paid,
        'partial' => RentStatus.partial,
        _         => RentStatus.pending,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      RentStatus.paid    => (const Color(0xFFDCFCE7), AppColors.paid, 'Paid'),
      RentStatus.partial => (const Color(0xFFFEF3C7), AppColors.partial, 'Partial'),
      RentStatus.pending => (const Color(0xFFFEE2E2), AppColors.pending, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chipRadius),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
```

### 7.8 InfoField

```dart
// lib/widgets/ui/info_field.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class InfoField extends StatelessWidget {
  final String label;
  final String? value;

  const InfoField({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.xs.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            (value?.trim().isEmpty ?? true) ? '-' : value!,
            style: AppText.base.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
```

### 7.9 StateCard

```dart
// lib/widgets/ui/state_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

enum StateCardVariant { info, error, empty }

class StateCard extends StatelessWidget {
  final String message;
  final Widget? icon;
  final StateCardVariant variant;

  const StateCard({
    super.key,
    required this.message,
    this.icon,
    this.variant = StateCardVariant.info,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (variant) {
      StateCardVariant.info  => (const Color(0xFFEDE9FE), const Color(0xFFC4B5FD)),
      StateCardVariant.error => (const Color(0xFFFEE2E2), const Color(0xFFFCA5A5)),
      StateCardVariant.empty => (const Color(0xFFF5F3FF), const Color(0xFFDDD6FE)),
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: AppSpacing.sm)],
          Text(message,
              textAlign: TextAlign.center,
              style: AppText.sm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
```

### 7.10 AppButton

```dart
// lib/widgets/ui/app_button.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

enum ButtonVariant { primary, secondary, ghost, outline }
enum ButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final Widget? leftIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.leftIcon,
  });

  @override
  Widget build(BuildContext context) {
    final padding = switch (size) {
      ButtonSize.sm => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ButtonSize.lg => const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    };
    final fontSize = switch (size) {
      ButtonSize.sm => 13.0,
      ButtonSize.md => 15.0,
      ButtonSize.lg => 17.0,
    };

    Widget child = isLoading
        ? SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == ButtonVariant.primary ? Colors.white : AppColors.violet,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leftIcon != null) ...[leftIcon!, const SizedBox(width: 8)],
              Text(label,
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.w600)),
            ],
          );

    final button = switch (variant) {
      ButtonVariant.primary => ElevatedButton(
          onPressed: (isLoading) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.violet,
            foregroundColor: Colors.white,
            padding: padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
            elevation: 0,
          ),
          child: child),
      ButtonVariant.secondary => ElevatedButton(
          onPressed: (isLoading) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3F4F6),
            foregroundColor: AppColors.textPrimary,
            padding: padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
            elevation: 0,
          ),
          child: child),
      ButtonVariant.ghost => TextButton(
          onPressed: (isLoading) ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.violet, padding: padding),
          child: child),
      ButtonVariant.outline => OutlinedButton(
          onPressed: (isLoading) ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.violet,
            padding: padding,
            side: const BorderSide(color: AppColors.violet, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
          child: child),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

### 7.11 AppTextField + FormField

```dart
// lib/widgets/ui/app_text_field.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: AppText.sm.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText && !_showPassword,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            style: AppText.base.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              errorText: widget.errorText,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(_showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── reactive_forms wrapper ───────────────────────────────────────────────────

import 'package:reactive_forms/reactive_forms.dart';

class ReactiveAppTextField extends StatelessWidget {
  final String formControlName;
  final String label;
  final String? placeholder;
  final bool obscureText;
  final TextInputType keyboardType;

  const ReactiveAppTextField({
    super.key,
    required this.formControlName,
    required this.label,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: formControlName,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
      ),
      validationMessages: {
        ValidationMessage.required: (_) => '$label is required',
        ValidationMessage.email: (_) => 'Invalid email address',
        ValidationMessage.minLength: (error) =>
            'Minimum ${(error as Map)['requiredLength']} characters',
        'mustMatch': (_) => 'Passwords do not match',
      },
    );
  }
}
```

### 7.12 SkeletonCard

```dart
// lib/widgets/ui/skeleton_card.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_tokens.dart';

class SkeletonCard extends StatelessWidget {
  final int lines;
  const SkeletonCard({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          boxShadow: const [AppShadow.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(lines, (i) => Container(
            height: 16,
            width: i == 0 ? 160 : double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          )),
        ),
      ),
    );
  }
}
```

### 7.13 FlatSelector

```dart
// lib/widgets/domain/flat_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_tokens.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../ui/app_bottom_sheet.dart';

class FlatModel {
  final String id, label, apartmentName, flatNumber;
  const FlatModel({
    required this.id,
    required this.label,
    required this.apartmentName,
    required this.flatNumber,
  });
}

class FlatSelector extends ConsumerWidget {
  final List<FlatModel> flats;
  const FlatSelector({super.key, required this.flats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFlatId = ref.watch(authProvider.select((s) => s.activeFlatId));
    final activeFlat = flats.firstWhere(
      (f) => f.id == activeFlatId,
      orElse: () => const FlatModel(
          id: '', label: 'Select Flat', apartmentName: '', flatNumber: ''),
    );
    final displayLabel =
        activeFlatId == 'all' ? 'All Flats' : activeFlat.label;

    final options = flats.length >= 2
        ? [
            const FlatModel(
                id: 'all', label: 'All Flats', apartmentName: '', flatNumber: ''),
            ...flats,
          ]
        : flats;

    return GestureDetector(
      onTap: () => AppBottomSheet.show(
        context,
        title: 'Select Unit',
        child: Column(
          children: options.map((flat) => ListTile(
            title: Text(flat.label,
                style: AppText.base.copyWith(fontWeight: FontWeight.w600)),
            subtitle: flat.apartmentName.isNotEmpty
                ? Text(flat.apartmentName)
                : null,
            tileColor: flat.id == activeFlatId
                ? const Color(0xFFEDE9FE)
                : null,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
            onTap: () {
              ref.read(authProvider.notifier).setActiveFlatId(flat.id);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(displayLabel, style: AppText.base.copyWith(fontWeight: FontWeight.w600)),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
```

### 7.14 RentBreakdownCard

```dart
// lib/widgets/domain/rent_breakdown_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/utils/currency_formatter.dart';
import '../ui/status_chip.dart';

class MaintenanceItem {
  final String item;
  final num totalCost, yourShare;
  const MaintenanceItem({required this.item, required this.totalCost, required this.yourShare});
}

class RentBreakdown {
  final num baseRent, utilityBill, maintenanceShare, previousDues, totalDue;
  final List<MaintenanceItem> maintenanceBreakdown;

  const RentBreakdown({
    required this.baseRent,
    required this.utilityBill,
    required this.maintenanceShare,
    required this.previousDues,
    required this.totalDue,
    this.maintenanceBreakdown = const [],
  });
}

class RentBreakdownCard extends StatefulWidget {
  final int month, year;
  final String status;
  final RentBreakdown breakdown;
  final num paidAmount;
  final String? apartmentName, flatNumber;

  const RentBreakdownCard({
    super.key,
    required this.month,
    required this.year,
    required this.status,
    required this.breakdown,
    required this.paidAmount,
    this.apartmentName,
    this.flatNumber,
  });

  @override
  State<RentBreakdownCard> createState() => _RentBreakdownCardState();
}

class _RentBreakdownCardState extends State<RentBreakdownCard> {
  bool _expanded = false;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final b = widget.breakdown;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        boxShadow: const [AppShadow.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_months[widget.month - 1]} ${widget.year}',
                    style: AppText.heading(18)),
                if (widget.apartmentName != null)
                  Text('${widget.apartmentName} · ${widget.flatNumber}',
                      style: AppText.xs.copyWith(color: AppColors.textSecondary)),
              ],
            )),
            StatusChip.fromString(widget.status),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Rows
          _Row(label: 'Base Rent', amount: b.baseRent),
          _Row(label: 'Electricity / Water', amount: b.utilityBill),

          // Maintenance with expand
          GestureDetector(
            onTap: b.maintenanceBreakdown.isNotEmpty
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Maintenance',
                      style: AppText.sm.copyWith(color: AppColors.textSecondary)),
                  Row(children: [
                    Text(formatINR(b.maintenanceShare),
                        style: AppText.sm.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500)),
                    if (b.maintenanceBreakdown.isNotEmpty)
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18, color: AppColors.violet),
                  ]),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...b.maintenanceBreakdown.map((item) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md, bottom: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${item.item} (Total: ${formatINR(item.totalCost)})',
                    style: AppText.xs.copyWith(color: AppColors.textSecondary)),
                Text('Your share: ${formatINR(item.yourShare)}',
                    style: AppText.xs.copyWith(color: AppColors.textPrimary)),
              ]),
            )),

          if (b.previousDues > 0)
            _Row(label: 'Previous Dues', amount: b.previousDues, highlight: true),

          const Divider(height: AppSpacing.lg),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Due', style: AppText.label(16)),
              Text(formatINR(b.totalDue),
                  style: AppText.label(16).copyWith(color: AppColors.violet)),
            ],
          ),
          if (widget.paidAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid',
                      style: AppText.sm.copyWith(color: AppColors.paid)),
                  Text(formatINR(widget.paidAmount),
                      style: AppText.sm.copyWith(
                          color: AppColors.paid, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final num amount;
  final bool highlight;
  const _Row({required this.label, required this.amount, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.pending : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.sm.copyWith(color: color)),
          Text(formatINR(amount),
              style: AppText.sm.copyWith(
                  color: highlight ? AppColors.pending : AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
```

### 7.15 NotificationCard

```dart
// lib/widgets/domain/notification_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final String title, message, targetType, expiresAt;
  final bool isExpired;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.targetType,
    required this.expiresAt,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isExpired
        ? [AppColors.expiredGradientStart, AppColors.expiredGradientEnd]
        : targetType == 'tenant'
            ? [AppColors.personalGradientStart, AppColors.personalGradientEnd]
            : [AppColors.apartmentGradientStart, AppColors.apartmentGradientEnd];

    final badge = targetType == 'tenant' ? 'Personal' : 'Apartment-wide';
    final icon = targetType == 'tenant' ? Icons.person_outline : Icons.apartment_outlined;

    final expiryDate = DateFormat('dd MMM yyyy')
        .format(DateTime.parse(expiresAt));

    return Opacity(
      opacity: isExpired ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppRadius.cardRadius,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: AppText.base.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(badge,
                    style: AppText.xs.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.sm.copyWith(color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 6),
            Text('Expires: $expiryDate',
                style: AppText.xs.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
```

### 7.16 SimplePaginator

```dart
// lib/widgets/domain/simple_paginator.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_tokens.dart';

class SimplePaginator extends StatelessWidget {
  final int page, totalPages;
  final VoidCallback onPrev, onNext;

  const SimplePaginator({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: page <= 1 ? null : onPrev,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Prev'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.violet.withOpacity(0.3),
            ),
          ),
          Text('Page $page of $totalPages',
              style: AppText.sm.copyWith(color: AppColors.textSecondary)),
          ElevatedButton.icon(
            onPressed: page >= totalPages ? null : onNext,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Next'),
            iconAlignment: IconAlignment.end,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.violet.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 8. Navigation (go_router)

```dart
// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// Shell widget — tab bar
import 'tab_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authProvider.notifier);

  return GoRouter(
    navigatorKey: DioClient.navigatorKey,
    initialLocation: '/login',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuth = auth.token != null;
      final mustChange = auth.mustChangePassword;
      final loc = state.matchedLocation;

      if (!isAuth && loc != '/login') return '/login';
      if (isAuth && mustChange && loc != '/change-password') return '/change-password';
      if (isAuth && !mustChange && (loc == '/login' || loc == '/change-password')) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),

      // Authenticated Shell (tab bar)
      ShellRoute(
        builder: (context, state, child) => TabShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/documents', builder: (_, __) => const DocumentsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
```

```dart
// lib/core/router/tab_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_tokens.dart';

class TabShell extends StatelessWidget {
  final Widget child;
  const TabShell({super.key, required this.child});

  static const _tabs = [
    (path: '/dashboard', label: 'Dashboard', icon: Icons.home_outlined,  activeIcon: Icons.home),
    (path: '/history',   label: 'History',   icon: Icons.history_outlined, activeIcon: Icons.history),
    (path: '/documents', label: 'Docs',      icon: Icons.description_outlined, activeIcon: Icons.description),
    (path: '/notifications', label: 'Alerts', icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
    (path: '/profile',   label: 'Profile',   icon: Icons.person_outline,   activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        items: _tabs.map((t) => BottomNavigationBarItem(
          icon: Icon(t.icon),
          activeIcon: Icon(t.activeIcon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
```

---

## 9. Authentication Flow

```
App Launch
    │
    ├── AuthNotifier._restoreSession()
    │       └── SecureStorageService.getToken()
    │           ├── null  → GoRouter redirects → /login
    │           └── found → restore AuthState
    │
    ├── mustChangePassword == true?
    │       ├── YES → redirect to /change-password
    │       └── NO  → redirect to /dashboard
    │
    └── GoRouter.redirect fires on every navigation

Login
    ├── POST /tenant/auth/login
    ├── SecureStorage.setToken(accessToken)
    ├── SharedPreferences: save userId, tenantKey, mustChangePassword
    ├── authProvider state updated → GoRouter.refreshListenable fires
    └── Redirect resolves to /change-password or /dashboard

Change Password
    ├── POST /tenant/change-password
    ├── SharedPreferences: mustChangePassword = false
    ├── authProvider.mustChangePassword = false → redirect fires
    └── Resolves to /dashboard

Logout
    ├── SecureStorage.clearToken()
    ├── SharedPreferences.clear()
    ├── dispatch(clearCredentials) → authProvider reset
    └── GoRouter redirect → /login
```

---

## 10. Screens

### 10.1 Login Screen

```dart
// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../widgets/ui/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'clientCode': FormControl<String>(
          validators: [Validators.required]),
      'email': FormControl<String>(
          validators: [Validators.required, Validators.email]),
      'password': FormControl<String>(
          validators: [Validators.required]),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    final values = _form.value;
    final error = await ref.read(authProvider.notifier).login(
      clientCode: values['clientCode'] as String,
      email: values['email'] as String,
      password: values['password'] as String,
    );
    if (error != null && mounted) {
      ToastService.showError('Login failed', error);
    }
    // Navigation handled by GoRouter redirect on authProvider change
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: ReactiveForm(
          formGroup: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text('Tenant Portal', style: AppText.heading(30).copyWith(color: AppColors.violet)),
                const SizedBox(height: 8),
                Text('Sign in to your account',
                    style: AppText.sm.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),
                ReactiveAppTextField(
                    formControlName: 'clientCode',
                    label: 'Client Code',
                    placeholder: 'e.g. PM001'),
                ReactiveAppTextField(
                    formControlName: 'email',
                    label: 'Email',
                    placeholder: 'you@example.com',
                    keyboardType: TextInputType.emailAddress),
                ReactiveAppTextField(
                    formControlName: 'password',
                    label: 'Password',
                    obscureText: true),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: isLoading,
                  fullWidth: true,
                  size: ButtonSize.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 10.2 Change Password Screen

```dart
// Zod equivalent: mustMatch validator in reactive_forms

final form = FormGroup({
  'currentPassword': FormControl<String>(validators: [Validators.required]),
  'newPassword': FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)]),
  'confirmPassword': FormControl<String>(validators: [Validators.required]),
}, validators: [
  Validators.mustMatch('newPassword', 'confirmPassword'),
]);

// On submit:
// await ref.read(authProvider.notifier).changePassword(...)
// Navigation handled by router redirect
```

### 10.3 Dashboard Screen

```dart
// lib/features/dashboard/screens/dashboard_screen.dart
// Key sections:

// 1. FlatSelector
// 2. NotificationCard (latest active) or StateCard("No active notifications")
// 3. Payment summary card (total outstanding)
// 4. RentBreakdownCard(s)
// 5. PaymentSplitGrid

// Data loading pattern with Riverpod:
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [
        IconButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout_outlined),
        ),
      ]),
      body: dashboardAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: List.generate(3, (_) => const SkeletonCard()),
        ),
        error: (e, _) => StateCard(
          message: 'Failed to load dashboard',
          variant: StateCardVariant.error,
          icon: const Icon(Icons.error_outline, color: AppColors.pending),
        ),
        data: (dashboard) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            FlatSelector(flats: dashboard.availableFlats
                .map((f) => FlatModel(
                    id: f.id,
                    label: f.label,
                    apartmentName: f.apartmentName,
                    flatNumber: f.flatNumber))
                .toList()),
            const SizedBox(height: AppSpacing.md),
            // ... notification banner, breakdown cards, etc.
          ],
        ),
      ),
    );
  }
}
```

**All Flats mode**: When `activeFlatId == 'all'`, use `Future.wait` to fetch all flat dashboards in parallel and render one `RentBreakdownCard` per flat.

### 10.4 History Screen

```dart
// Uses historyProvider(HistoryParams(flatId, page))
// FutureProvider.family with HistoryParams as key

// Renders:
// 1. FlatSelector
// 2. RentStackedBarChart + RentTrendLineChart (if items.length >= 2)
// 3. ListView of RentBreakdownCard
// 4. SimplePaginator (hidden in All Flats mode)

// Page reset on flat change:
ref.listen(authProvider.select((s) => s.activeFlatId), (prev, next) {
  if (prev != next) setState(() => _page = 1);
});
```

### 10.5 Notifications Screen

```dart
// Reads notification data from dashboardProvider (same endpoint)
// Splits into active / expired lists

// Renders:
// Header: "Notifications" + counts subtitle
// Section "Active" → NotificationCard list
// Section "Expired" → same cards, opacity 0.6 (handled by isExpired flag)
// Empty: StateCard("No notifications found", variant: StateCardVariant.empty)
```

### 10.6 Documents Screen

```dart
// lib/features/documents/screens/documents_screen.dart

import 'package:url_launcher/url_launcher.dart';

Future<void> _openDocument(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ToastService.showError('Cannot open document');
  }
}

// Renders:
// "Tenant Documents" section (blue icon)
// "Unit Documents" section grouped by apartment + unit
// Each doc: filename, upload date, TextButton("View") → _openDocument(url)
// No FlatSelector — documents are tenant-scoped
// Empty state: dashed border Container with Icon(Icons.error_outline)
```

### 10.7 Profile Screen

```dart
// Renders 9 InfoField widgets in a ListView
// Loading: StateCard("Loading profile...")
// Error:   StateCard("Unable to load profile", variant: StateCardVariant.error)
// No FlatSelector — profile is tenant-scoped

// Fields:
// Name, Email, Phone, Alternate Phone, Aadhaar (masked), PAN (masked),
// Emergency Contact Name, Emergency Contact Relation, Emergency Phone
```

---

## 11. Backend API Contracts

### 11.1 No New Endpoints Required

All existing `/tenant/*` REST endpoints work identically. Dio sends the same JSON payloads and Bearer token headers.

### 11.2 Required Backend Configuration

```
1. No CORS concerns — native apps don't use browser CORS
   (Only needed if you add a Flutter Web target)

2. Token TTL — extend for mobile sessions:
   Access token:  15 minutes
   Refresh token: 30 days (store in SecureStorage)

3. Push Notifications (future):
   POST /tenant/device-token
   Body: { deviceToken: string, platform: "ios" | "android" }
   Purpose: Register FCM/APNs token for server-triggered push
```

### 11.3 Refresh Token Flow (Recommended)

```
POST /tenant/auth/login → { accessToken, refreshToken }

Dio interceptor on 401:
  1. SecureStorage.getRefreshToken()
  2. POST /tenant/auth/refresh → { accessToken }
  3. SecureStorage.setToken(newAccessToken)
  4. Retry original request with new token
  5. If refresh fails (401) → logout, go to /login
```

### 11.4 Recommended Backend Tech Stack

| Layer        | Technology                 | Notes                                  |
| ------------ | -------------------------- | -------------------------------------- |
| Runtime      | **Node.js 20 LTS**         | Unchanged                              |
| Framework    | **NestJS**                 | Guards, interceptors, pipes            |
| Language     | **TypeScript**             | Strict mode                            |
| ORM          | **Prisma** or **TypeORM**  | Multi-tenant schema                    |
| Database     | **PostgreSQL**             | Row-level or schema-per-tenant         |
| Auth         | **JWT** (access + refresh) | `@nestjs/jwt`                          |
| Password     | **bcrypt** (salt ≥ 12)     | Unchanged                              |
| File Storage | **AWS S3** pre-signed URLs | 30-min expiry                          |
| Validation   | **class-validator**        | DTO validation                         |
| Push         | **Firebase Admin SDK**     | FCM for Android + APNs via FCM for iOS |

### 11.5 NestJS Backend Structure

```
backend/src/
├── modules/
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts        # POST /tenant/auth/login, /refresh
│   │   └── strategies/jwt.strategy.ts
│   ├── tenant/
│   │   ├── dashboard.controller.ts   # GET /tenant/dashboard
│   │   ├── history.controller.ts     # GET /tenant/history
│   │   ├── profile.controller.ts     # GET /tenant/profile
│   │   ├── documents.controller.ts   # GET /tenant/documents
│   │   └── change-password.controller.ts
│   └── notifications/
│       └── device-token.controller.ts # POST /tenant/device-token
├── guards/
│   ├── jwt-auth.guard.ts
│   ├── tenant-active.guard.ts
│   └── must-change-password.guard.ts
└── interceptors/
    └── client-db.interceptor.ts      # Multi-tenant DB routing
```

---

## 12. Environment & Config

### `.env` Files

```bash
# assets/.env.development
API_URL=http://localhost:3000
APP_ENV=development

# assets/.env.production
API_URL=https://api.tenant.app.com
APP_ENV=production
```

### Load env in `main.dart`

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env based on compile-time flavor
  const env = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  await dotenv.load(fileName: 'assets/.env.$env');

  runApp(const ProviderScope(child: App()));
}
```

### `pubspec.yaml` — register env as asset

```yaml
flutter:
    assets:
        - assets/.env.development
        - assets/.env.production
```

### Run with flavor

```bash
# Development
flutter run --dart-define=APP_ENV=development

# Production
flutter build apk --dart-define=APP_ENV=production
flutter build ipa --dart-define=APP_ENV=production
```

### Utility: Currency & Date Formatting

```dart
// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
String formatINR(num amount) => _inr.format(amount);
```

```dart
// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

String formatDate(String isoDate) =>
    DateFormat('dd MMM yyyy', 'en_IN').format(DateTime.parse(isoDate));

String formatDateTime(String isoDate) =>
    DateFormat('dd MMM yyyy, hh:mm a', 'en_IN').format(DateTime.parse(isoDate));

String monthYear(int month, int year) =>
    DateFormat('MMM yyyy').format(DateTime(year, month));
```

---

## 13. Testing Checklist

### Auth

- [ ] Login with valid clientCode + email + password → Dashboard
- [ ] Login with wrong credentials → error toast, stays on login
- [ ] Login with `needsPasswordChange: true` → Change Password screen
- [ ] Change Password: mismatched confirm → mustMatch error shown inline
- [ ] Change Password success → Dashboard; no redirect on subsequent login
- [ ] 401 on any API call → SecureStorage cleared, navigate to Login

### Dashboard

- [ ] Single flat: correct rent breakdown renders
- [ ] Multi-flat: FlatSelector bottom sheet shows all options + "All Flats"
- [ ] All Flats mode: one `RentBreakdownCard` per flat
- [ ] Notification banner: latest active notification shown
- [ ] No notifications: `StateCard("No active notifications")` shown
- [ ] Maintenance expand/collapse toggle works
- [ ] Previous Dues row only visible when > 0

### History

- [ ] Paginated correctly (10 per page, Prev/Next buttons)
- [ ] Bar + Line charts render when ≥ 2 history items
- [ ] Switching flat resets to page 1
- [ ] All Flats: pagination hidden, all data merged + sorted descending

### Notifications

- [ ] Active and Expired sections shown
- [ ] Personal = violet gradient, Apartment-wide = amber gradient
- [ ] Expired cards = 60% opacity
- [ ] Empty state `StateCard` shown when no notifications

### Documents

- [ ] "View" opens pre-signed URL in external browser
- [ ] No `FlatSelector` on this screen
- [ ] Empty state shown when no documents
- [ ] Upload date formatted correctly (en-IN locale)

### Profile

- [ ] All 9 `InfoField` rows displayed
- [ ] Empty optional fields show "-"
- [ ] Aadhaar and PAN are masked (backend-side, never unmasked)

### Cross-Platform

- [ ] Android: back button pops correctly in go_router
- [ ] Android: status bar color matches AppBar
- [ ] iOS: safe area insets respected (top notch, bottom home bar)
- [ ] iOS: `flutter_secure_storage` uses Keychain correctly
- [ ] Tablet (768px+): consider adaptive layout (two-column) in dashboard

---

_Generated: April 2026 | Stack: Flutter 3.22 · Dart 3.4 · Riverpod 2 · go_router 14_
