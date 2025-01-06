class AuthResult {
  final String token;
  final String expiry;
  final int userId;

  AuthResult({
    required this.token,
    required this.expiry,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiry': expiry,
      'user_id': userId,
    };
  }
}
