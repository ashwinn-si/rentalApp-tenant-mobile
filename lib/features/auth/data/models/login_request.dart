class LoginRequest {
  const LoginRequest({
    required this.clientCode,
    required this.email,
    required this.password,
  });

  final String clientCode;
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'clientCode': clientCode,
      'email': email,
      'password': password,
    };
  }
}
