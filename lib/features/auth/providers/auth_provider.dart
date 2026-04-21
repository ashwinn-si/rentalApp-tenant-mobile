import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../services/fcm_service.dart';
import '../data/auth_repository.dart';
import '../data/models/login_request.dart';
import '../data/models/login_response.dart';

class AuthState {
  const AuthState({
    this.token,
    this.userId,
    this.tenantKey,
    this.activeFlatId,
    this.mustChangePassword = false,
    this.isLoading = false,
    this.error,
    this.enabledScreens = const [],
  });

  final String? token;
  final String? userId;
  final String? tenantKey;
  final String? activeFlatId;
  final bool mustChangePassword;
  final bool isLoading;
  final String? error;
  final List<String> enabledScreens;

  bool hasScreen(String screenKey) => enabledScreens.contains(screenKey);

  AuthState copyWith({
    String? token,
    String? userId,
    String? tenantKey,
    String? activeFlatId,
    bool? mustChangePassword,
    bool? isLoading,
    String? error,
    List<String>? enabledScreens,
  }) {
    return AuthState(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      tenantKey: tenantKey ?? this.tenantKey,
      activeFlatId: activeFlatId ?? this.activeFlatId,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      enabledScreens: enabledScreens ?? this.enabledScreens,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  final AuthRepository _repository = AuthRepository();

  Future<void> _restoreSession() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    DioClient.instance.setSessionToken(token);

    final prefs = await SharedPreferences.getInstance();
    final rawScreens = prefs.getStringList('enabledScreens') ?? [];
    state = state.copyWith(
      token: token,
      userId: prefs.getString('userId'),
      tenantKey: prefs.getString('tenantKey'),
      activeFlatId: prefs.getString('activeFlatId'),
      mustChangePassword: prefs.getBool('mustChangePassword') ?? false,
      enabledScreens: rawScreens,
      error: null,
    );
  }

  Future<String?> login({
    required String clientCode,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.login(
      LoginRequest(clientCode: clientCode, email: email, password: password),
    );

    if (!result.isSuccess || result.data == null) {
      state = state.copyWith(
          isLoading: false, error: result.error ?? 'Login failed');
      return state.error;
    }

    final LoginResponse loginData = result.data!;
    final accessToken = loginData.accessToken.trim();
    if (accessToken.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: token missing in response',
      );
      return state.error;
    }

    DioClient.instance.setSessionToken(accessToken);
    await SecureStorageService.setToken(accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', loginData.user.id);
    await prefs.setString('tenantKey', loginData.user.tenantKey);
    await prefs.setBool('mustChangePassword', loginData.mustChangePassword);
    await prefs.setStringList('enabledScreens', loginData.enabledScreens);

    state = state.copyWith(
      isLoading: false,
      token: accessToken,
      userId: loginData.user.id,
      tenantKey: loginData.user.tenantKey,
      mustChangePassword: loginData.mustChangePassword,
      enabledScreens: loginData.enabledScreens,
      error: null,
    );

    try {
      final fcmToken = FcmService.getToken() ?? await FcmService.refreshToken();
      if (fcmToken != null && fcmToken.trim().isNotEmpty) {
        await _repository.registerFcmToken(fcmToken: fcmToken.trim());
      }
    } catch (_) {
      // Ignore FCM registration errors so authentication still succeeds.
    }

    return null;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!result.isSuccess) {
      state = state.copyWith(
          isLoading: false, error: result.error ?? 'Change failed');
      return state.error;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mustChangePassword', false);
    state = state.copyWith(
        isLoading: false, mustChangePassword: false, error: null);
    return null;
  }

  Future<void> setActiveFlatId(String flatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeFlatId', flatId);
    state = state.copyWith(activeFlatId: flatId, error: null);
  }

  Future<void> logout() async {
    DioClient.instance.setSessionToken(null);
    await SecureStorageService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.token != null));
});
