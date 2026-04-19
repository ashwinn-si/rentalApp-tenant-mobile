class LoginUser {
  const LoginUser({
    required this.id,
    required this.tenantKey,
  });

  final String id;
  final String tenantKey;

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: (json['id'] ?? '').toString(),
      tenantKey: (json['tenantKey'] ?? '').toString(),
    );
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.user,
    required this.mustChangePassword,
    required this.enabledScreens,
  });

  final String accessToken;
  final LoginUser user;
  final bool mustChangePassword;
  final List<String> enabledScreens;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Backend response helper wraps payload under "data".
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final userJson = (payload['user'] is Map<String, dynamic>)
        ? payload['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawScreens = payload['enabledScreens'];
    final enabledScreens = rawScreens is List
        ? rawScreens.map((e) => e.toString()).toList()
        : <String>[];

    return LoginResponse(
      // Support both token and accessToken key names for compatibility.
      accessToken:
          ((payload['token'] ?? payload['accessToken']) ?? '').toString(),
      user: LoginUser.fromJson(userJson),
      mustChangePassword: payload['mustChangePassword'] == true,
      enabledScreens: enabledScreens,
    );
  }
}
