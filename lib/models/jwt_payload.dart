class JwtPayload {
  final int userId;
  final String email;

  JwtPayload({
    required this.userId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
    };
  }

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    return JwtPayload(
      userId: json['userId'],
      email: json['email'],
    );
  }
}
