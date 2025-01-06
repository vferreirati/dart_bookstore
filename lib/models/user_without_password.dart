class UserWithoutPassword {
  final int id;
  final String name;
  final String email;

  UserWithoutPassword({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserWithoutPassword.fromRow(List<dynamic> row) {
    return UserWithoutPassword(
      id: row[0],
      name: row[1],
      email: row[2],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
