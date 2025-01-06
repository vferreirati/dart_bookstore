class User {
  final int id;
  final String name;
  final String email;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.fromRow(List<dynamic> row) {
    return User(
      id: row[0],
      name: row[1],
      email: row[2],
      password: row[3],
    );
  }
}
